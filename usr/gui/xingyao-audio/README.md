# Xingyao 14 audio

On `techrevo` (MECHREVO XINGYAO Series-P916F-STX, Realtek ALC256 subsystem `1d05:e004`), the default HiFi/UCM profile selects AMD ACP-PDM capture, which produced a saturated constant signal.
Bypassing ACP for the Realtek card exposes its working HDA PCM.
A user service enables capture and the normal speakers whenever WirePlumber starts or restarts; PipeWire still controls listening volume.
The service checks the board and codec identity before changing mixer controls.

After switching from HiFi, select the new nodes as defaults once in the audio settings:

- Input: `alsa_input.pci-0000_c1_00.6.capture.0.0`
- Output: `alsa_output.pci-0000_c1_00.6.playback.0.0`

WirePlumber saves these selections.
The rule is restricted to `techrevo`, following the repo's existing `/etc/hostname` convention.
There is no speaker-pin retasking or kernel patch.
Automatic jack/profile handling is bypassed for this card; headset insertion and suspend/resume need separate verification.

## Evidence and references

- [Exact-model report, GOKORURI](https://www.cnblogs.com/gokoruri/p/23071181): same board, codec and subsystem; bypasses ACP and initializes speaker switches.
- [Related Fedora discussion](https://discussion.fedoraproject.org/t/lenovo-yoga-pro-7-14asp9-83hn-dead-digital-microphone-fix/206126): a different ALC287 laptop also selects an unusable digital microphone; its virtual-microphone workaround is not used here.
- [WirePlumber ALSA documentation](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html): documents `api.alsa.use-acp`, UCM selection and device matching.

On this laptop, a timed recording through the raw HDA PipeWire source contained user-confirmed speech after the hardware speaker switches were enabled for playback.
After Home Manager activation, a WirePlumber restart preserved the HDA defaults, capture/speaker switches, and the user's listening volume.
The earlier direct-ALSA test without confirmed speaking timing did not establish that HDA was broken.

Run module checks with `nix eval -f usr/gui/xingyao-audio/test.nix` on `techrevo`.
