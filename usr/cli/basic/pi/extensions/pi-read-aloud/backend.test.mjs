import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdtemp, readFile, rm, stat } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { spawn } from 'node:child_process';

const root = process.env.READ_ALOUD_PACKAGE ?? new URL('.', import.meta.url).pathname;
const backendUrl = pathToFileURL(join(root, 'backend.mjs')).href;
const { Kokoro } = await import(backendUrl);
const modelDir = process.env.READ_ALOUD_MODEL;
assert(modelDir, 'Run through check.nix or set READ_ALOUD_MODEL');

async function fixture(t) {
  const dir = await mkdtemp(join(tmpdir(), 'read-aloud-backend-'));
  const logPath = join(dir, 'native.log');
  const backend = new Kokoro({ modelDir, logPath });
  t.after(async () => { await backend.close(); await rm(dir, { recursive: true, force: true }); });
  return { backend, logPath };
}
function valid(audio) {
  assert(audio.samples instanceof Float32Array);
  assert.equal(audio.sampleRate, 24000);
  assert(audio.samples.length > 2400);
  assert(audio.samples.every(Number.isFinite));
  assert(audio.samples.some(x => Math.abs(x) > 0.01));
}

test('native synthesis stays outside the parent and writes only to its private log', { timeout: 60000 }, async t => {
  const dir = await mkdtemp(join(tmpdir(), 'read-aloud-isolation-'));
  t.after(() => rm(dir, { recursive: true, force: true }));
  const logPath = join(dir, 'native.log');
  const code = `
    import { Kokoro } from ${JSON.stringify(backendUrl)};
    import { readFileSync } from 'node:fs';
    const engine = new Kokoro({ modelDir: process.env.READ_ALOUD_MODEL, logPath: ${JSON.stringify(logPath)} });
    try {
      const clips = [];
      for (const text of ['你好，语音准备好了。', 'The server manager drinks water.', '检查 tokenizer 和 server。']) {
        const a = await engine.synthesize(text);
        clips.push({ rate: a.sampleRate, length: a.samples.length, finite: a.samples.every(Number.isFinite), audible: a.samples.some(x => Math.abs(x) > .01) });
      }
      if (readFileSync('/proc/self/maps', 'utf8').includes('libsherpa-onnx')) throw Error('Native runtime leaked into parent');
      console.log(JSON.stringify(clips));
    } finally { await engine.close(); }
  `;
  const proc = spawn(process.execPath, ['--input-type=module', '-e', code], { stdio: ['ignore', 'pipe', 'pipe'] });
  t.after(() => proc.kill('SIGKILL'));
  let stdout = '', stderr = '';
  proc.stdout.on('data', x => stdout += x);
  proc.stderr.on('data', x => stderr += x);
  const exit = await new Promise((resolve, reject) => { proc.on('error', reject); proc.on('close', resolve); });
  assert.equal(exit, 0, stderr);
  assert.equal(stderr, '');
  const clips = JSON.parse(stdout);
  assert.equal(clips.length, 3);
  for (const clip of clips) assert(clip.rate === 24000 && clip.length > 2400 && clip.finite && clip.audible);
  const log = await readFile(logPath, 'utf8');
  assert.match(log, /Unknown token/);
  assert.equal(log.match(/Unknown token: ❓/g)?.length, 1, 'Reuse one loaded model across requests');
  assert.equal((await stat(logPath)).mode & 0o777, 0o600);
});

test('cancel during model loading and synthesize again without a stuck worker', { timeout: 60000 }, async t => {
  const { backend } = await fixture(t);
  const abort = new AbortController();
  const pending = backend.synthesize('你好。', { signal: abort.signal });
  abort.abort();
  await assert.rejects(pending, { name: 'AbortError' });
  valid(await backend.synthesize('Hello again.'));
});

test('reject empty, oversized and pre-cancelled requests before starting native work', async t => {
  const { backend, logPath } = await fixture(t);
  await assert.rejects(backend.synthesize(' '), /empty/i);
  await assert.rejects(backend.synthesize('a'.repeat(601)), /600/);
  await assert.rejects(backend.synthesize('Hello', { signal: AbortSignal.abort() }), { name: 'AbortError' });
  await assert.rejects(stat(logPath), { code: 'ENOENT' });
});

test('bad model paths produce a normal error instead of killing the caller', { timeout: 10000 }, async t => {
  const dir = await mkdtemp(join(tmpdir(), 'read-aloud-missing-'));
  const backend = new Kokoro({ modelDir: join(dir, 'missing'), logPath: join(dir, 'native.log') });
  t.after(async () => { await backend.close(); await rm(dir, { recursive: true, force: true }); });
  await assert.rejects(backend.synthesize('Hello.'), /model|ENOENT/i);
});

test('native worker crashes reject promptly and the next request restarts it', { timeout: 60000 }, async t => {
  const { backend } = await fixture(t);
  const childrenFile = `/proc/${process.pid}/task/${process.pid}/children`;
  const before = new Set((await readFile(childrenFile, 'utf8')).trim().split(/\s+/));
  const pending = backend.synthesize('This request will be interrupted.');
  const rejected = assert.rejects(pending, /exited|disconnected/);
  await assert.rejects(backend.synthesize('Do not queue unlimited work.'), /busy/);
  const children = (await readFile(childrenFile, 'utf8')).trim().split(/\s+/);
  const pid = children.find(pid => pid && !before.has(pid));
  assert(pid, 'A separate worker must exist');
  process.kill(Number(pid), 'SIGKILL');
  await rejected;
  valid(await backend.synthesize('Recovered.'));
  await backend.close();
  assert.equal((await readFile(childrenFile, 'utf8')).trim(), [...before].join(' ').trim());
});

test('close rejects pending synthesis and reaps the child', { timeout: 10000 }, async t => {
  const { backend } = await fixture(t);
  const pending = backend.synthesize('This request is cancelled by shutdown.');
  const rejected = assert.rejects(pending, { name: 'AbortError' });
  await backend.close();
  await rejected;
});
