# Pi voicekit

CPU-only read-aloud using the auditioned Kokoro v1.1 FP32 model and `af_maple` (speaker 0).
The package uses four CPU threads, the US-English and Chinese lexicons, and the same number/date/phone normalization rules as the audition.
Fcitx5 vinput remains the input method; voicekit dictation, preview, punctuation downloads, and automatic narration are disabled.

After Home Manager activation, start a new Pi process with stderr redirected to keep native warnings out of the terminal:

```sh
pi 2>>/tmp/pi-stderr.log
```

This appends all Pi stderr, including unrelated diagnostics, to the log.
It does not change pronunciation; the upstream runtime still skips unsupported phonemes.

Commands:

- `/voice-speak`: wait for the agent to finish, then read the latest assistant text on the current branch; omit code blocks and clean Markdown.
- `/voice-speak some text`: read explicit text.
- `/voice-speak-stop`: cancel speech.
- `/voice-speak-info`: inspect the selected model and voice.

`tts.patch` adds the missing v1.1 FP32 catalogue entry, preserves the audition's inference settings, adds the no-argument command behavior, and suppresses dictation setup when input is disabled.
Keep these changes narrow when updating the upstream pin.
The model archive and npm dependency graph are hash-pinned.
The upstream native runtime and model assets are used without pronunciation patches; native libraries are patched only for Nix dependency paths.

Checks:

```sh
nix eval -f usr/cli/basic/pi/extensions/pi-voicekit/test.nix
nix-build usr/cli/basic/pi/extensions/pi-voicekit/check.nix --no-out-link
```

The second check runs the local command/configuration regressions, upstream TTS tests, actual Pi extension loading, and real CPU synthesis in disposable homes without microphone or speaker access.
Its mixed-language text exercises English “er” sounds and technical terms; native synthesis must produce finite, non-silent audio.
Native diagnostics are captured in `native-stderr.log` alongside `native-result.json` in the check output.
