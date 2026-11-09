import { spawn } from 'node:child_process';
import { createInterface } from 'node:readline';

/** One mpv per reply, with bounded read-ahead and a private inherited IPC socket. */
export class Player {
  #ipc;
  #requests = new Map();
  #sequence = 0;
  #error;
  #closed = false;

  constructor({ command = 'mpv', paused = false } = {}) {
    const child = this.process = spawn(command, [
      '--no-config', '--no-terminal', '--no-video', '--audio-display=no',
      '--input-terminal=no', '--input-ipc-client=fd://3',
      '--demuxer=rawaudio', '--demuxer-rawaudio-format=floatle',
      '--demuxer-rawaudio-rate=24000', '--demuxer-rawaudio-channels=mono',
      '--cache=no', '--demuxer-max-bytes=262144', '--demuxer-max-back-bytes=0',
      `--pause=${paused ? 'yes' : 'no'}`, '-',
    ], { stdio: ['pipe', 'ignore', 'pipe', 'pipe'] });
    this.#ipc = child.stdio[3];
    this.closed = new Promise(resolve => child.once('close', resolve));
    let diagnostic = '';
    child.stderr.on('data', data => { diagnostic = (diagnostic + data.toString()).slice(-4096); });
    this.done = new Promise((resolve, reject) => {
      child.once('close', (code, signal) => {
        this.#closed = true;
        if (!this.#error && code !== 0) this.#error = new Error(`mpv exited (${signal ?? code}): ${diagnostic.trim()}`);
        for (const finish of this.#requests.values()) finish(this.#error ?? new Error('Playback ended'));
        if (this.#error) reject(this.#error); else resolve();
      });
    });
    this.done.catch(() => {}); // Errors remain observable even before the caller reaches end().
    child.on('error', error => this.#fail(error));
    child.stdin.on('error', error => this.#fail(error));
    this.#ipc.on('error', error => this.#fail(error));
    createInterface({ input: this.#ipc }).on('line', line => {
      try {
        const reply = JSON.parse(line);
        this.#requests.get(reply.request_id)?.(reply.error === 'success' ? undefined : new Error(`mpv: ${reply.error}`), reply.data);
      } catch (error) { this.#fail(error); }
    }).on('error', error => this.#fail(error));
  }

  #fail(error) {
    if (this.#closed) return;
    this.#error ??= error;
    for (const finish of this.#requests.values()) finish(this.#error);
    this.process.kill('SIGKILL');
  }

  async write(samples) {
    if (this.#error) throw this.#error;
    if (this.process.stdin.writableEnded || this.#closed) throw new Error('Playback ended');
    const pcm = Buffer.from(samples.buffer, samples.byteOffset, samples.byteLength);
    await new Promise((resolve, reject) => {
      this.process.stdin.write(pcm, error => {
        if (this.#error || error) reject(this.#error ?? error); else resolve();
      });
    });
  }

  async command(command) {
    if (this.#error) throw this.#error;
    if (this.#closed) throw new Error('Playback ended');
    const id = ++this.#sequence;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => this.#fail(new Error('mpv control timed out')), 5000);
      const finish = (error, value) => {
        clearTimeout(timer);
        this.#requests.delete(id);
        if (error) reject(error); else resolve(value);
      };
      this.#requests.set(id, finish);
      this.#ipc.write(JSON.stringify({ command, request_id: id }) + '\n', error => {
        if (error) this.#fail(error);
      });
    });
  }

  setPaused(paused) { return this.command(['set_property', 'pause', paused]); }

  async end() {
    if (!this.process.stdin.writableEnded && !this.#closed) this.process.stdin.end();
    return this.done;
  }

  async stop() {
    this.#fail(new DOMException('Playback cancelled', 'AbortError'));
    await this.closed;
  }
}
