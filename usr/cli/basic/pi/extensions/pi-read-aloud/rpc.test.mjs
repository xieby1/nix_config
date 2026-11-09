import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdtemp, mkdir, symlink, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { setTimeout as sleep } from 'node:timers/promises';

const { PI_ROOT, READ_ALOUD_PACKAGE: root, READ_ALOUD_MODEL: model } = process.env;
assert(PI_ROOT && root && model, 'Run through check.nix');
const { RpcClient } = await import(pathToFileURL(join(PI_ROOT, 'dist/modes/rpc/rpc-client.js')));

test('actual Pi RPC commands, session replacement and stdin shutdown reap speech processes', { timeout: 60000 }, async t => {
  const home = await mkdtemp(join(tmpdir(), 'read-aloud-rpc-'));
  const agent = join(home, '.pi/agent');
  await mkdir(agent, { recursive: true });
  await mkdir(join(home, '.pi/models/tts'), { recursive: true });
  await symlink(model, join(home, '.pi/models/tts/kokoro-multi-lang-v1_1'));
  const client = new RpcClient({
    cliPath: join(PI_ROOT, 'dist/cli.js'), cwd: home,
    env: { HOME: home, PI_CODING_AGENT_DIR: agent },
    args: ['--offline', '--no-session', '--no-extensions', '--no-skills', '--no-prompt-templates', '-e', root],
  });
  t.after(async () => {
    if (client.process && client.process.exitCode === null && client.process.signalCode === null) await client.stop();
    await rm(home, { recursive: true, force: true });
  });
  const events = [];
  client.onEvent(event => events.push(event));
  await client.start();
  const proc = client.process;
  const stdout = [];
  proc.stdout.on('data', data => { stdout.push(data); });
  const children = async () => (await readFile(`/proc/${proc.pid}/task/${proc.pid}/children`, 'utf8')).trim().split(/\s+/).filter(Boolean);
  const players = async () => {
    const result = [];
    for (const pid of await children()) {
      try { if ((await readFile(`/proc/${pid}/cmdline`, 'utf8')).includes('--demuxer=rawaudio')) result.push(pid); } catch (e) { if (e.code !== 'ENOENT') throw e; }
    }
    return result;
  };
  const until = async check => {
    for (let i = 0; i < 400; i++) { if (await check()) return; await sleep(25); }
    throw new Error(`RPC speech timed out: ${JSON.stringify(events)} ${client.getStderr()}`);
  };
  const commands = (await client.getCommands()).map(command => command.name);
  assert(commands.includes('voice-speak') && commands.includes('voice-speak-stop'));
  assert.equal(await client.prompt('/voice-speak'), 'handled');
  assert.deepEqual(await children(), []);
  assert.equal(await client.prompt('/voice-speak 你好，server 已经准备好了。This is a real Pi speech test.'), 'handled');
  await until(async () => (await players()).length === 1);
  assert.equal(await client.prompt('/voice-speak-stop'), 'handled');
  assert.deepEqual(await players(), []);

  await client.prompt('/voice-speak Change sessions while this sentence is being spoken.');
  await until(async () => (await players()).length === 1);
  await client.newSession();
  assert.deepEqual(await children(), []);
  await client.prompt('/voice-speak Close the input stream while this sentence is being spoken.');
  await until(async () => (await players()).length === 1);
  const descendants = await children();
  const exited = new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error('Pi did not shut down')), 10000);
    proc.once('close', code => { clearTimeout(timeout); resolve(code); });
  });
  proc.stdin.end();
  assert.equal(await exited, 0);
  for (const pid of descendants) await assert.rejects(readFile(`/proc/${pid}/stat`), { code: 'ENOENT' });
  assert.equal(client.getStderr(), '');
  for (const line of Buffer.concat(stdout).toString('utf8').trim().split('\n')) JSON.parse(line);
  assert.match(await readFile(join(agent, 'read-aloud.log'), 'utf8'), /Unknown token/);
  assert(!events.some(event => event.type === 'agent_start'), 'Speech commands must not start an LLM run');
});
