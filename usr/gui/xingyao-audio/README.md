# Xingyao 14 audio

On `techrevo` (MECHREVO XINGYAO Series-P916F-STX, Realtek ALC256 subsystem `1d05:e004`), the default HiFi/UCM profile selects AMD ACP-PDM capture, which produces a saturated constant signal.
The BIOS also leaves the second speaker pin `0x1b` disconnected, causing thin, quiet playback.

## Home Manager routing and mixer

The host-scoped WirePlumber rule disables ACP for the Realtek card, exposing its working HDA PCM.
A hardware-checked user service enables Master, Speaker and Capture at 0 dB whenever WirePlumber starts or restarts.
PipeWire controls listening volume.

Select these defaults once; WirePlumber saves them:

- Input: `alsa_input.pci-0000_c1_00.6.capture.0.0`
- Output: `alsa_output.pci-0000_c1_00.6.playback.0.0`

The output node explicitly uses `audio.channels = 2` and `audio.position = [ "FL" "FR" ]`.
This is required with the patched driver: raw ALSA enumeration otherwise negotiates four channels, placing the shared speaker DAC on channels 3/4 while stereo audio reaches channels 1/2, resulting in silence.
With two-channel PCM playback, both speaker and headphone DACs receive the stereo stream.
The input configuration is unaffected by this output-only rule.

ACP profile/port management is bypassed; ALSA headphone auto-mute was verified separately on this machine.

## Driver fix and power saving

The companion [NixOS module](../../../sys/gui/xingyao-audio/default.nix) applies [a small patch](../../../sys/gui/xingyao-audio/alc256-xingyao-speakers.patch) to the configured Xanmod kernel on `techrevo`.
It registers pin `0x1b` as an internal speaker (`0x90170121`) and restricts it to DAC `0x02`, shared with pin `0x14`.
The quirk matches PCI subsystem `1d05:e004` and checks the ALC256 codec and codec subsystem before applying.
The driver then owns initialization and restoration of both speaker paths.

Normal boot uses this patch, masks the old `xingyao-speakers.service`, and omits its resume command.
The codec keeps `power/control=auto`, sleeps while idle and restores full speaker sound on playback.
The kernel version string is unchanged; use `/run/booted-system/kernel` to identify the actual kernel build.

For an idle/wake check, inspect `/sys/bus/hdaudio/devices/hdaudioC<card>D0/power/runtime_status` before reading the codec dump, because reading registers wakes the chip.
Pause playback and recording, then allow up to 35 seconds for PipeWire to close the PCM and the codec's 10-second autosuspend timer to expire.
Expect `runtime_status=suspended` and `power/control=auto`.
During subsequent playback, verify stereo PCM, speaker DAC `0x02` on channel 0, and pins `0x14` and `0x1b` output-enabled and unmuted.

Hardware verification covered full sound after repeated codec idle/wake cycles, recognizable microphone recording, wired headphones with speaker auto-mute, speaker restoration after unplugging, actual laptop suspend/resume, and microphone recording after resume.
The kernel was boot-tested; the stereo rule was then activated and verified across a WirePlumber restart and laptop suspend/resume.

## Fallback

The `xingyao-speakers-workaround` boot entry uses the unpatched kernel and the previously tested userspace workaround.
Its system service checks board, codec, subsystem, DAC selection and EAPD, resolves the codec device from `Generic_1`, then enables `0x1b` with raw HDA verbs.
A resume hook restarts the service.
It keeps only this codec's `power/control=on`, because raw verb settings reset after codec autosuspend; this may increase idle power consumption.
Stopping that fallback service restores the original pin input/mute state and `power/control=auto`.
Use the fallback boot entry if the patched driver regresses after a kernel update.

## References and checks

- [Exact-model report, GOKORURI](https://www.cnblogs.com/gokoruri/p/23071181): same board, codec and subsystem; ACP bypass, hardware gain and the second speaker path.
- [Related ALC256 shared-DAC driver patch](https://lore.kernel.org/linux-sound/20260927210455.13938-1-mfthesun@vivaldi.net/): routing approach for a different laptop; its unrelated pin settings are not copied.
- [Related Fedora microphone discussion](https://discussion.fedoraproject.org/t/lenovo-yoga-pro-7-14asp9-83hn-dead-digital-microphone-fix/206126): a different ALC287 laptop selects an unusable digital microphone.
- [WirePlumber ALSA documentation](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html).

```sh
nix eval -f usr/gui/xingyao-audio/test.nix # on techrevo
nix eval -f sys/gui/xingyao-audio/test.nix
python3 sys/gui/xingyao-audio/test.py
```
