# Pi read aloud

TTS-only integration for the selected Kokoro v1.1 FP32 model: `af_maple` (speaker 0), speed 1, four CPU threads.
The original model, English/Chinese lexicons and Chinese normalization FSTs are preserved.
No native pronunciation patches or runtime downloads are used.

## Controls

- **Alt+R:** idle → read the latest completed, speakable assistant reply; reading → pause the current reply, even if a newer reply exists; paused → resume the same reply, or replace it if a newer reply exists.
- **`/voice-speak`:** wait for the agent to settle, then read its latest reply.
- **`/voice-speak text`:** read supplied text immediately.
- **`/voice-speak-stop`:** stop playback and cancel any read command still waiting for the agent.

Reply identity is the session entry ID, not text equality.
Only persisted assistant text from the current branch is selected; thinking, tool output, failed/aborted messages and code blocks are excluded.
Basic Markdown formatting is removed; inline names remain speakable.
Sentences are generated one at a time in chunks of at most 400 UTF-16 code units, without splitting surrogate pairs.
Pause during synthesis holds the completed audio until resume and prevents further synthesis while paused.

Playback does not display a footer status; failures use Pi notifications, never direct terminal output.
Session shutdown/reload/switch closes both processes; tree navigation stops the current read.
Nothing starts at extension load or agent completion: there is no automatic narration, dictation, model browser, HTTP server or settings framework.
Fcitx5 vinput is unaffected.
The model remains at `~/.pi/models/tts/kokoro-multi-lang-v1_1`; native diagnostics go to `<Pi agent directory>/read-aloud.log` (normally `~/.pi/agent/read-aloud.log`).

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

## Home Manager

`default.nix` installs the local npm package, the unchanged model symlink and mpv on x86-64/AArch64 Linux.
It replaces the old voicekit module/pin and does not change Pi settings or the Pi launcher.
No manual stderr redirection is needed.
After a Home Manager activation, restart Pi or run `/reload` to unload the old extension.
Building and testing this module does not activate it.

## Verification

```sh
nix eval -f usr/cli/basic/pi/extensions/pi-read-aloud/test.nix
nix-build usr/cli/basic/pi/extensions/pi-read-aloud/check.nix --no-out-link
```

The check builds the native npm dependency with Nix ELF fixups and runs under a disposable HOME.
It exercises actual Chinese, English and mixed-language synthesis, checks finite audible samples, proves native diagnostics stay out of the parent terminal and native libraries stay out of the parent process, verifies model reuse, and tests cancellation, shutdown, worker crashes and recovery.
Playback tests use actual mpv with `--ao=null`: its real playback clock must freeze/resume, a paused write must apply backpressure, EOF must finish cleanly, and cancellation must reap the process without uncaught socket errors.
Control tests cover newer replies (including identical text with different IDs), pause during synthesis, rapid controls, cleanup and failures.
The installed Pi loader also runs the registered commands/shortcut through actual native synthesis and mpv, checking empty startup, cancelled idle waits, branch changes, explicit speech, stop and shutdown with clean parent output.
A separate real Pi RPC process verifies slash-command dispatch without starting an LLM run, session replacement, active-playback shutdown on stdin EOF, child-process reaping, valid JSONL output and empty stderr.
