import { speechChunks } from './text.mjs';

/** Own one reply at a time; controls never wait for the whole reply to finish. */
export class Reader {
  #run;
  #settled = Promise.resolve();
  #closed = false;

  constructor({ backend, createPlayer, onState, onError }) {
    Object.assign(this, { backend, createPlayer, onState, onError });
  }

  get state() { return this.#run ? (this.#run.paused ? 'paused' : 'reading') : 'idle'; }

  toggle(reply) {
    if (this.#closed) return;
    const run = this.#run;
    if (run && (!run.paused || !reply || run.id === reply.id)) {
      run.paused = !run.paused;
      if (!run.paused) run.wake?.();
      this.onState(this.state);
      run.player?.setPaused(run.paused).catch(error => {
        if (this.#run !== run) return;
        this.onError(error);
        void this.stop();
      });
    } else { this.start(reply); }
  }

  start(reply) {
    if (this.#closed || !reply?.text.trim()) return;
    const previous = this.stop();
    const run = { ...reply, paused: false, abort: new AbortController(), player: undefined, wake: undefined };
    this.#run = run;
    this.onState('reading');
    this.#settled = this.#play(run, previous).catch(error => {
      if (!run.abort.signal.aborted && this.#run === run) this.onError(error);
    }).finally(() => {
      if (this.#run === run) { this.#run = undefined; this.onState('idle'); }
    });
  }

  async #unpaused(run) {
    while (run.paused && !run.abort.signal.aborted) await new Promise(resolve => { run.wake = resolve; });
    run.wake = undefined;
    run.abort.signal.throwIfAborted();
  }

  async #play(run, previous) {
    try {
      await previous;
      for (const chunk of speechChunks(run.text)) {
        await this.#unpaused(run);
        const audio = await this.backend.synthesize(chunk, { signal: run.abort.signal });
        await this.#unpaused(run);
        run.player ??= this.createPlayer({ paused: run.paused });
        await run.player.write(audio.samples);
      }
      await run.player?.end();
    } finally { await run.player?.stop(); }
  }

  stop() {
    const run = this.#run;
    this.#run = undefined;
    if (run) {
      run.abort.abort();
      run.wake?.();
      void run.player?.stop();
      this.onState('idle');
    }
    return this.#settled;
  }

  close() {
    if (!this.#closed) {
      this.#closed = true;
      const stopped = this.stop();
      this.#settled = stopped.then(() => this.backend.close());
    }
    return this.#settled;
  }
}
