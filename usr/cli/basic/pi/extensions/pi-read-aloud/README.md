# Pi read aloud

TTS-only integration for the selected Kokoro v1.1 FP32 model: `af_maple` (speaker 0), speed 1, four CPU threads.
The original model, English/Chinese lexicons and Chinese normalization FSTs are preserved.
No native pronunciation patches or runtime downloads are used.

## Synthesis

`backend.mjs` exposes `Kokoro({ modelDir, logPath })`, `synthesize(text, { signal })` and `close()`.
A request accepts at most 600 UTF-16 code units; only one request may be active.
The caller splits longer replies instead of retaining an entire reply's audio.

`worker.mjs` is the only process that loads sherpa-onnx.
It keeps the model warm across requests and returns mono 24 kHz float samples over IPC.
Its stdout/stderr go directly to the specified append-only log, created with mode 0600.
The log may contain text/phonemes from the reply; it is not a general Pi stderr log.
Known native pronunciation diagnostics remain in the log without modifying the model.

Cancellation terminates the private worker and discards the current chunk; the next request reloads the model.
`close()` rejects active work and waits for children to exit; a worker also exits when its parent disconnects.
Synthesis failures and unexpected worker exits reject normally instead of crashing Pi.

## Playback

`player.mjs` owns one mpv process per reply.
Mono float PCM arrives through stdin; JSON commands and acknowledgements use inherited fd 3, with no public socket.
`write()` applies backpressure, `setPaused()` waits for mpv's acknowledgement, and `end()` waits until the last audio finishes.
`stop()` rejects pending work and reaps the process.
A player can start paused, so a pause during synthesis never leaks the first audio.
mpv configuration files and terminal input are disabled; read-ahead is capped at 256 KiB.
Player diagnostics are captured and bounded, not printed into Pi.

## Verification

```sh
nix-build usr/cli/basic/pi/extensions/pi-read-aloud/check.nix --no-out-link
```

The check builds the native npm dependency with Nix ELF fixups and runs under a disposable HOME.
It exercises actual Chinese, English and mixed-language synthesis, checks finite audible samples, proves native diagnostics stay out of the parent terminal and native libraries stay out of the parent process, verifies model reuse, and tests cancellation, shutdown, worker crashes and recovery.
Playback tests use actual mpv with `--ao=null`: its real playback clock must freeze/resume, a paused write must apply backpressure, EOF must finish cleanly, and cancellation must reap the process without uncaught socket errors.
