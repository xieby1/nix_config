import assert from 'node:assert/strict';
import { test } from 'node:test';
import { setTimeout as sleep } from 'node:timers/promises';
import { pathToFileURL } from 'node:url';
import { join } from 'node:path';
const root = process.env.READ_ALOUD_PACKAGE ?? new URL('.', import.meta.url).pathname;
const { Player } = await import(pathToFileURL(join(root, 'player.mjs')).href);

const command = process.env.READ_ALOUD_MPV;
assert(command, 'Set READ_ALOUD_MPV to the null-output mpv wrapper');
const samples = seconds => new Float32Array(24000 * seconds).fill(0.01);
const make = (t, paused = false) => {
  const player = new Player({ command, paused });
  t.after(() => player.stop());
  return player;
};
async function position(player) {
  for (let i = 0; i < 40; i++) {
    try { return await player.command(['get_property', 'time-pos']); } catch (e) {
      if (!/property unavailable/.test(e.message)) throw e;
    }
    await sleep(50);
  }
  throw new Error('mpv never started playback');
}

test('real mpv clock freezes on pause and continues on resume', { timeout: 10000 }, async t => {
  const player = make(t);
  const written = player.write(samples(8)).catch(error => error);
  await position(player);
  await sleep(250);
  await player.setPaused(true);
  assert.equal(await player.command(['get_property', 'pause']), true);
  const pausedAt = await position(player);
  await sleep(250);
  assert(Math.abs(await position(player) - pausedAt) < 0.03);
  await player.setPaused(false);
  await sleep(250);
  assert(await position(player) > pausedAt + 0.1);
  await player.stop();
  await written;
  await assert.rejects(player.done, { name: 'AbortError' });
});

test('initial pause keeps audio silent and backpressure bounds queued PCM', { timeout: 10000 }, async t => {
  const player = make(t, true);
  let settled = false;
  const written = player.write(samples(60)).then(() => { settled = true; }, error => { settled = true; return error; });
  assert.equal(await player.command(['get_property', 'pause']), true);
  await sleep(300);
  assert.equal(settled, false, 'Do not accept unlimited audio while paused');
  await player.stop();
  assert.equal((await written).name, 'AbortError');
});

test('end waits for short audio to finish and reaps mpv', { timeout: 10000 }, async t => {
  const player = make(t);
  await player.write(samples(0.2));
  await player.end();
  assert.equal(player.process.exitCode, 0);
  await player.end();
});

test('stop rejects pending controls and reaps a paused player', { timeout: 10000 }, async t => {
  const player = make(t, true);
  const query = player.command(['get_property', 'pause']).catch(error => error);
  await player.stop();
  await query;
  await assert.rejects(player.done, { name: 'AbortError' });
  assert(player.process.exitCode !== null || player.process.signalCode !== null);
});

test('missing player errors stay in promises rather than uncaught events', { timeout: 10000 }, async t => {
  const player = new Player({ command: '/missing/pi-read-aloud-mpv' });
  t.after(() => player.stop());
  await assert.rejects(player.done, /ENOENT/);
  await assert.rejects(player.write(samples(1)), /ENOENT/);
});
