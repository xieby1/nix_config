import os
from pathlib import Path
import subprocess
import tempfile
import unittest


class SpeakerTest(unittest.TestCase):
    def setUp(self):
        source = Path(__file__).with_name("initialize.sh")
        self.assertTrue(source.exists(), "speaker initialization script is missing")
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.codec = self.root / "proc/asound/card7/codec#0"
        self.board = self.root / "sys/class/dmi/id/board_name"
        self.power = self.root / "sys/bus/hdaudio/devices/hdaudioC7D0/power/control"
        for path in (self.codec, self.board, self.power):
            path.parent.mkdir(parents=True, exist_ok=True)
        self.board.write_text("XINGYAO Series-P916F-STX\n")
        self.power.write_text("auto\n")
        self.codec.write_text("""Vendor Id: 0x10ec0256
Subsystem Id: 0x1d05e004
Node 0x1b [Pin Complex]
  Amp-Out vals:  [0x80 0x80]
  EAPD 0x2: EAPD
  Pin-ctls: 0x20: IN
  Connection: 2
     0x02* 0x03
Node 0x1c [Vendor Defined Widget]
""")
        (self.root / "proc/asound/Generic_1").symlink_to("card7")
        self.script = self.root / "initialize.sh"
        script = source.read_text()
        for prefix in ("/sys/", "/proc/", "/dev/"):
            script = script.replace(prefix, str(self.root) + prefix)
        self.script.write_text(script)
        mock = self.root / "hda-verb"
        mock.write_text("""#!/usr/bin/env python3
import os, pathlib, re, sys
codec = pathlib.Path(os.environ['TEST_CODEC'])
with open(os.environ['TEST_LOG'], 'a') as log:
    log.write(' '.join(sys.argv[1:]) + chr(10))
verb, value = sys.argv[3:]
if os.environ.get('FAIL_UNMUTE') == '1' and value == '0xb000':
    sys.exit(1)
text = codec.read_text()
if verb == 'SET_PIN_WIDGET_CONTROL':
    text = re.sub(r'Pin-ctls: .*', 'Pin-ctls: ' + value + ': ' + ('OUT' if value == '0x40' else 'IN'), text)
else:
    amp = '00' if value == '0xb000' else '80'
    text = re.sub(r'Amp-Out vals: .*', f'Amp-Out vals:  [0x{amp} 0x{amp}]', text)
codec.write_text(text)
""")
        mock.chmod(0o755)
        self.log = self.root / "verbs.log"
        self.env = dict(os.environ, PATH=str(self.root) + os.pathsep + os.environ["PATH"],
                        TEST_CODEC=str(self.codec), TEST_LOG=str(self.log))

    def run_script(self, mode):
        return subprocess.run(["bash", str(self.script), mode], env=self.env,
                              capture_output=True, text=True)

    def test_apply_and_restore_with_nondefault_card_number(self):
        result = self.run_script("on")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.power.read_text(), "on\n")
        self.assertIn("Pin-ctls: 0x40: OUT", self.codec.read_text())
        self.assertIn("[0x00 0x00]", self.codec.read_text())
        self.assertEqual(self.log.read_text().splitlines(), [
            f"{self.root}/dev/snd/hwC7D0 0x1b SET_PIN_WIDGET_CONTROL 0x40",
            f"{self.root}/dev/snd/hwC7D0 0x1b SET_AMP_GAIN_MUTE 0xb000",
        ])
        result = self.run_script("off")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.power.read_text(), "auto\n")
        self.assertIn("Pin-ctls: 0x20: IN", self.codec.read_text())
        self.assertIn("[0x80 0x80]", self.codec.read_text())

    def test_reject_unknown_hardware_without_writes(self):
        cases = [(self.board, "P916F-STX", "other-board"),
                 (self.codec, "0x10ec0256", "0x10ec0287"),
                 (self.codec, "0x1d05e004", "0x1d05e005"),
                 (self.codec, "0x02* 0x03", "0x02 0x03*"),
                 (self.codec, "EAPD 0x2", "EAPD 0x0")]
        for path, before, after in cases:
            with self.subTest(before=before):
                original = path.read_text()
                path.write_text(original.replace(before, after))
                self.assertNotEqual(self.run_script("on").returncode, 0)
                self.assertFalse(self.log.exists())
                self.assertEqual(self.power.read_text(), "auto\n")
                path.write_text(original)

    def test_restore_after_failed_unmute(self):
        self.env["FAIL_UNMUTE"] = "1"
        self.assertNotEqual(self.run_script("on").returncode, 0)
        self.assertEqual(self.power.read_text(), "auto\n")
        self.assertIn("Pin-ctls: 0x20: IN", self.codec.read_text())
        self.assertIn("[0x80 0x80]", self.codec.read_text())

    def test_reject_invalid_action_without_writes(self):
        self.assertNotEqual(self.run_script("invalid").returncode, 0)
        self.assertFalse(self.log.exists())
        self.assertEqual(self.power.read_text(), "auto\n")


if __name__ == "__main__":
    unittest.main()
