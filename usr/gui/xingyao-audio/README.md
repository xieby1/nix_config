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
Both enabled speaker pins use DAC `0x02`, so two-channel PCM sends the same stereo stream to both speaker paths.
The input configuration is unaffected by this output-only rule.

ACP profile/port management is bypassed; ALSA headphone auto-mute was verified separately on this machine.

## Userspace speaker fix and power saving

The companion [NixOS module](../../../sys/gui/xingyao-audio/default.nix) starts `xingyao-speakers.service` on `techrevo` without patching or rebuilding the kernel.
The service checks the board, codec, subsystem, DAC selection and EAPD, resolves the codec device from `Generic_1`, then enables pin `0x1b` with raw HDA verbs.
Both speaker pins use the already selected DAC `0x02`.
A resume hook restarts the service after system suspend.

The service keeps only this codec's `power/control=on`, because raw verb settings reset after codec autosuspend.
Consequently the codec does not runtime-suspend while the service is active, which may increase idle power consumption.
Stopping the service restores the original pin input/mute state and `power/control=auto`.

During playback, verify stereo PCM and pins `0x14` and `0x1b` output-enabled and unmuted.
Headphone auto-mute and speaker restoration after unplugging should also be checked after changing the audio configuration.

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
