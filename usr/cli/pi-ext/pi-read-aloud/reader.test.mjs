import assert from 'node:assert/strict';
import { test } from 'node:test';
import { setImmediate as tick } from 'node:timers/promises';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
const root = process.env.READ_ALOUD_PACKAGE ?? new URL('.', import.meta.url).pathname;
const { Reader } = await import(pathToFileURL(join(root, 'reader.mjs')).href);
const reply = (id, text = 'Hello.') => ({ id, text });
const deferred = () => Promise.withResolvers();

function setup(t, delayed = false) {
  const calls = [], players = [], states = [], errors = [], synthesis = [];
  let closed = 0;
  const backend = {
    async synthesize(text, { signal }) {
      calls.push(text);
      if (delayed) {
        const gate = deferred();
        synthesis.push(gate);
        const abort = () => gate.reject(new DOMException('Aborted', 'AbortError'));
        signal.addEventListener('abort', abort, { once: true });
        try { await gate.promise; } finally { signal.removeEventListener('abort', abort); }
      }
      signal.throwIfAborted();
      return { samples: new Float32Array(2400), sampleRate: 24000 };
    },
    async close() { closed++; },
  };
  const reader = new Reader({
    backend,
    createPlayer({ paused }) {
      const eof = deferred();
      const player = {
        paused, writes: 0, stopped: false, controls: [],
        async write() { this.writes++; },
        async setPaused(value) { this.paused = value; this.controls.push(value); },
        async end() { await eof.promise; },
        async stop() { this.stopped = true; eof.resolve(); },
        finish() { eof.resolve(); },
      };
      players.push(player);
      return player;
    },
    onState: state => states.push(state),
    onError: error => errors.push(error),
  });
  t.after(() => reader.close());
  return { reader, backend, calls, players, states, errors, synthesis, get closed() { return closed; } };
}

test('reading always pauses the current reply even when a newer reply exists', async t => {
  const f = setup(t);
  f.reader.toggle(reply('one')); await tick();
  f.reader.toggle(reply('two', 'New.')); await tick();
  assert.equal(f.reader.state, 'paused');
  assert.deepEqual(f.calls, ['Hello.']);
  assert.equal(f.players[0].paused, true);
  assert.equal(f.players[0].stopped, false);
});

test('paused unchanged reply resumes without another synthesis', async t => {
  const f = setup(t);
  f.reader.toggle(reply('one')); await tick();
  f.reader.toggle(reply('one'));
  f.reader.toggle(reply('one')); await tick();
  assert.equal(f.reader.state, 'reading');
  assert.deepEqual(f.players[0].controls, [true, false]);
  assert.equal(f.calls.length, 1);
});

test('paused newer reply replaces the old player even when text is identical', async t => {
  const f = setup(t);
  f.reader.toggle(reply('one')); await tick();
  f.reader.toggle(reply('two'));
  f.reader.toggle(reply('two')); await tick();
  assert.equal(f.reader.state, 'reading');
  assert.equal(f.players[0].stopped, true);
  assert.equal(f.players.length, 2);
  assert.deepEqual(f.calls, ['Hello.', 'Hello.']);
});

test('pause during synthesis holds the audio until resume', async t => {
  const f = setup(t, true);
  f.reader.toggle(reply('one')); await tick();
  f.reader.toggle(reply('one'));
  f.synthesis[0].resolve(); await tick();
  assert.equal(f.reader.state, 'paused');
  assert.equal(f.players.length, 0);
  f.reader.toggle(reply('one')); await tick();
  assert.equal(f.players[0].writes, 1);
});

test('rapid replacement and toggles keep a single current run', async t => {
  const f = setup(t, true);
  f.reader.toggle(reply('one')); await tick();
  f.reader.toggle(reply('two', 'New.'));
  f.reader.toggle(reply('two', 'New.'));
  f.reader.toggle(reply('two', 'New.'));
  f.reader.toggle(reply('two', 'New.'));
  await tick();
  assert.equal(f.reader.state, 'reading');
  assert.deepEqual(f.calls, ['Hello.', 'New.']);
  f.synthesis.at(-1).resolve(); await tick();
  assert.equal(f.players.filter(p => !p.stopped).length, 1);
  assert.deepEqual(f.errors, []);
});

test('stop releases paused work and prevents further chunks', async t => {
  const f = setup(t, true);
  f.reader.toggle(reply('one', 'First. Second.')); await tick();
  f.reader.toggle(reply('one'));
  await f.reader.stop();
  assert.equal(f.reader.state, 'idle');
  assert.equal(f.calls.length, 1);
  assert.equal(f.players.length, 0);
  assert.deepEqual(f.errors, []);
});

test('natural EOF clears status and releases the player', async t => {
  const f = setup(t);
  f.reader.toggle(reply('one')); await tick();
  f.players[0].finish(); await tick();
  assert.equal(f.reader.state, 'idle');
  assert.equal(f.states.at(-1), 'idle');
  assert.equal(f.players[0].stopped, true);
});

test('synthesis and control failures notify once and stop the read', async t => {
  const f = setup(t);
  f.backend.synthesize = async () => { throw new Error('native failure'); };
  f.reader.toggle(reply('one')); await tick();
  assert.equal(f.errors[0].message, 'native failure');
  assert.equal(f.reader.state, 'idle');
  f.backend.synthesize = async () => ({ samples: new Float32Array(2400), sampleRate: 24000 });
  f.reader.toggle(reply('two')); await tick();
  f.players[0].setPaused = async () => { throw new Error('control failed'); };
  f.reader.toggle(reply('two')); await tick();
  assert.equal(f.errors.at(-1).message, 'control failed');
  assert.equal(f.errors.length, 2);
  assert.equal(f.reader.state, 'idle');
});

test('closing waits for cleanup and forbids stale commands from restarting speech', async t => {
  const f = setup(t, true);
  f.reader.toggle(reply('one')); await tick();
  await f.reader.close();
  f.reader.toggle(reply('two')); await tick();
  assert.equal(f.calls.length, 1);
  assert.equal(f.closed, 1);
  assert.equal(f.reader.state, 'idle');
});

test('empty conversations do nothing and do not construct a player', async t => {
  const f = setup(t);
  f.reader.toggle(undefined); await tick();
  assert.equal(f.reader.state, 'idle');
  assert.equal(f.calls.length, 0);
  assert.equal(f.players.length, 0);
});
