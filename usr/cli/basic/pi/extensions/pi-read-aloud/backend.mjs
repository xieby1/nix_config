import { fork } from 'node:child_process';
import { closeSync, fchmodSync, mkdirSync, openSync } from 'node:fs';
import { dirname } from 'node:path';

/** One warm, private native process; one bounded synthesis request at a time. */
export class Kokoro {
  #worker;
  #pending;
  #children = new Set();

  constructor({ modelDir, logPath }) {
    this.modelDir = modelDir;
    this.logPath = logPath;
  }

  async synthesize(text, { signal } = {}) {
    signal?.throwIfAborted();
    if (typeof text !== 'string' || !text.trim()) throw new Error('Speech text is empty');
    if (text.length > 600) throw new Error('Speech chunks must not exceed 600 characters');
    if (this.#pending) throw new Error('Synthesis is already busy');
    const worker = this.#worker ?? this.#start();
    return new Promise((resolve, reject) => {
      const finish = (error, audio) => {
        if (this.#pending?.worker !== worker) return;
        this.#pending = undefined;
        signal?.removeEventListener('abort', abort);
        worker.child.channel?.unref();
        if (error) reject(error); else resolve(audio);
      };
      const abort = () => { void this.close(); };
      this.#pending = { worker, finish };
      signal?.addEventListener('abort', abort, { once: true });
      worker.child.channel?.ref();
      worker.child.send({ text }, error => { if (error) finish(error); });
    });
  }

  #start() {
    mkdirSync(dirname(this.logPath), { recursive: true, mode: 0o700 });
    const log = openSync(this.logPath, 'a', 0o600);
    let child;
    try {
      fchmodSync(log, 0o600);
      child = fork(new URL('./worker.mjs', import.meta.url), [this.modelDir], {
        execArgv: [], serialization: 'advanced', stdio: ['ignore', log, log, 'ipc'],
      });
    } finally { closeSync(log); }
    const worker = { child, closed: new Promise(resolve => child.once('close', resolve)) };
    this.#worker = worker;
    this.#children.add(worker);
    const fail = error => {
      if (this.#worker === worker) this.#worker = undefined;
      if (this.#pending?.worker === worker) this.#pending.finish(error);
    };
    child.on('message', message => {
      if (this.#pending?.worker !== worker) return;
      if (message.error) { this.#pending.finish(new Error(message.error)); return; }
      const { samples, sampleRate } = message;
      if (!(samples instanceof Float32Array) || !samples.length || sampleRate !== 24000 || !samples.every(Number.isFinite)) {
        this.#pending.finish(new Error('Kokoro returned invalid audio'));
        return;
      }
      this.#pending.finish(undefined, { samples, sampleRate });
    });
    child.on('error', fail);
    child.on('exit', (code, signal) => fail(new Error(`Speech worker exited (${signal ?? code}); see ${this.logPath}`)));
    child.on('disconnect', () => {
      fail(new Error(`Speech worker disconnected; see ${this.logPath}`));
      child.kill('SIGKILL');
    });
    child.on('close', () => this.#children.delete(worker));
    child.unref();
    child.channel?.unref();
    return worker;
  }

  async close() {
    this.#pending?.finish(new DOMException('Speech cancelled', 'AbortError'));
    this.#worker = undefined;
    const children = [...this.#children];
    // Native inference cannot be reliably interrupted inside the process.
    for (const { child } of children) { child.ref(); child.kill('SIGKILL'); }
    await Promise.all(children.map(worker => worker.closed));
  }
}
