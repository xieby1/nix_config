import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdir, mkdtemp, readFile, stat, symlink } from 'node:fs/promises';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { setTimeout as sleep } from 'node:timers/promises';

const { PI_ROOT, READ_ALOUD_PACKAGE: root, READ_ALOUD_MODEL: model, READ_ALOUD_TEST_HOME: home } = process.env;
assert(PI_ROOT && root && model && home && homedir() === home, 'Run in the disposable check.nix environment');
await mkdir(join(home, '.pi/models/tts'), { recursive: true });
await symlink(model, join(home, '.pi/models/tts/kokoro-multi-lang-v1_1'));
const { discoverAndLoadExtensions } = await import(pathToFileURL(join(PI_ROOT, 'dist/core/extensions/loader.js')));
const children = async () => (await readFile(`/proc/${process.pid}/task/${process.pid}/children`, 'utf8')).trim().split(/\s+/).filter(Boolean);
async function players() {
  const result = [];
  for (const pid of await children()) {
    try { if ((await readFile(`/proc/${pid}/cmdline`, 'utf8')).includes('--demuxer=rawaudio')) result.push(pid); } catch (e) { if (e.code !== 'ENOENT') throw e; }
  }
  return result;
}
async function until(check) {
  for (let i = 0; i < 400; i++) { const value = await check(); if (value) return value; await sleep(25); }
  throw new Error('Timed out waiting for speech state');
}
async function load(t) {
  const agent = await mkdtemp(join(home, 'agent-'));
  const cwd = join(home, 'project');
  await mkdir(cwd, { recursive: true });
  process.env.PI_CODING_AGENT_DIR = agent;
  const loaded = await discoverAndLoadExtensions([root], cwd, agent);
  assert.deepEqual(loaded.errors, []);
  assert.equal(loaded.extensions.length, 1);
  const extension = loaded.extensions[0];
  const notices = [], statuses = [], branch = [];
  const ctx = {
    cwd, hasUI: true, mode: 'rpc',
    ui: { notify: (message, level) => notices.push({ message, level }), setStatus: (key, value) => statuses.push(value) },
    sessionManager: { getBranch: () => branch },
    waitForIdle: async () => {},
  };
  const emit = async name => { for (const handler of extension.handlers.get(name) ?? []) await handler({ reason: 'quit' }, ctx); };
  t.after(() => emit('session_shutdown'));
  await emit('session_start');
  return { extension, ctx, notices, statuses, branch, emit, log: join(agent, 'read-aloud.log') };
}

test('loads only the manual controls and does not start background resources', async t => {
  const before = await children();
  const f = await load(t);
  assert.deepEqual([...f.extension.commands.keys()].sort(), ['voice-speak', 'voice-speak-stop']);
  assert.deepEqual([...f.extension.shortcuts.keys()], ['alt+r']);
  assert.equal(f.extension.tools.size, 0);
  assert(!f.extension.handlers.has('agent_end'));
  await f.extension.commands.get('voice-speak').handler('', f.ctx);
  assert(f.notices.some(n => /No assistant reply/.test(n.message)));
  await assert.rejects(stat(f.log), { code: 'ENOENT' });
  assert.deepEqual(await children(), before);
});

test('stop cancels a read command that is still waiting for the agent', async t => {
  const f = await load(t);
  const idle = Promise.withResolvers();
  f.ctx.waitForIdle = () => idle.promise;
  const pending = f.extension.commands.get('voice-speak').handler('', f.ctx);
  await f.extension.commands.get('voice-speak-stop').handler('', f.ctx);
  idle.resolve(); await pending;
  assert.deepEqual(f.notices, []);
  await assert.rejects(stat(f.log), { code: 'ENOENT' });
});

test('session shutdown invalidates pending commands before they resume', async t => {
  const f = await load(t);
  const idle = Promise.withResolvers();
  f.ctx.waitForIdle = () => idle.promise;
  const pending = f.extension.commands.get('voice-speak').handler('', f.ctx);
  await f.emit('session_shutdown');
  idle.resolve(); await pending;
  assert.deepEqual(f.notices, []);
  await assert.rejects(stat(f.log), { code: 'ENOENT' });
});

test('real Pi controls drive isolated native synthesis and mpv then clean up on branch change and shutdown', { timeout: 60000 }, async t => {
  const before = await children();
  const f = await load(t);
  const shortcut = f.extension.shortcuts.get('alt+r').handler;
  const answer = id => ({ id, type: 'message', message: { role: 'assistant', stopReason: 'stop', content: [{ type: 'text', text: '你好，这是暂停测试。The server manager drinks water.' }] } });
  f.branch.push(answer('one'));
  f.ctx.waitForIdle = () => { throw new Error('A shortcut must not wait for the agent'); };
  await shortcut(f.ctx);
  await shortcut(f.ctx);
  assert.match(f.statuses.at(-1), /paused/i);
  await sleep(100);
  assert.deepEqual(await players(), []);
  await shortcut(f.ctx);
  const original = await until(async () => (await players())[0]);
  f.branch.push(answer('two'));
  await shortcut(f.ctx);
  assert.match(f.statuses.at(-1), /paused/i);
  assert.deepEqual(await players(), [original], 'A newer answer must not replace a currently reading answer on the first keypress');
  await shortcut(f.ctx);
  const replacement = await until(async () => (await players()).find(pid => pid !== original));
  assert(replacement);
  assert.match(f.statuses.at(-1), /reading/i);
  await f.emit('session_tree');
  assert.deepEqual(await players(), []);
  assert.equal(f.statuses.at(-1), undefined);
  await f.extension.commands.get('voice-speak').handler('Explicit speech still works. 中文也可以。', f.ctx);
  await until(async () => (await players())[0]);
  await f.extension.commands.get('voice-speak-stop').handler('', f.ctx);
  assert.deepEqual(await players(), []);
  assert.equal(f.statuses.at(-1), undefined);
  await f.emit('session_shutdown');
  assert.deepEqual(await children(), before);
  assert.deepEqual(f.notices, []);
  assert.match(await readFile(f.log, 'utf8'), /Unknown token/);
  assert(!(await readFile('/proc/self/maps', 'utf8')).includes('libsherpa-onnx'));
});
