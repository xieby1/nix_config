#!/usr/bin/env python3
"""Run with: nix-shell -p jq --run 'python3 usr/gui/firefox/apps/singleton.test.py'"""
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("singleton.sh")
FAKE_NIRI = r'''#!/usr/bin/env python3
import json, os, sys
p = os.environ["FAKE_NIRI"]
s = json.load(open(p))
w = s["windows"]
a = sys.argv[1:]
def col(win):
    pos = win["layout"]["pos_in_scrolling_layout"]
    return pos[0] if pos else 0
def save():
    with open(p, "w") as f: json.dump(s, f)
if a[:2] == ["msg", "--json"]:
    print(json.dumps(s[a[2]]))
    sys.exit()
assert a[:2] == ["msg", "action"], a
s["actions"].append(a[2:])
act = a[2]
if act == "focus-window":
    for win in w: win["is_focused"] = win["id"] == int(a[-1])
else:
    target = next(win for win in w if win["id"] == int(a[a.index("--id") + 1])) if "--id" in a else next(win for win in w if win["is_focused"])
    old = col(target)
    ws = target["workspace_id"]
    if act == "move-window-to-monitor":
        if old and not any(win is not target and win["workspace_id"] == ws and col(win) == old for win in w):
            for win in w:
                if win["workspace_id"] == ws and col(win) > old: win["layout"]["pos_in_scrolling_layout"][0] -= 1
        new_ws = next(workspace["id"] for workspace in s["workspaces"] if workspace["output"] == a[-1])
        target["workspace_id"] = new_ws
        if old: target["layout"]["pos_in_scrolling_layout"] = [max((col(win) for win in w if win is not target and win["workspace_id"] == new_ws), default=0) + 1, 1]
    elif act == "move-window-to-tiling":
        target["is_floating"] = False
        target["layout"]["pos_in_scrolling_layout"] = [max((col(win) for win in w if win["workspace_id"] == ws), default=0) + 1, 1]
    elif act == "consume-or-expel-window-right":
        assert any(win is not target and win["workspace_id"] == ws and col(win) == old for win in w)
        for win in w:
            if win["workspace_id"] == ws and col(win) > old: win["layout"]["pos_in_scrolling_layout"][0] += 1
        target["layout"]["pos_in_scrolling_layout"][0] = old + 1
    elif act == "move-column-to-index":
        dest = int(a[-1])
        assert not any(win is not target and win["workspace_id"] == ws and col(win) == old for win in w)
        for win in w:
            if win["workspace_id"] == ws and ((old < col(win) <= dest) or (dest <= col(win) < old)):
                win["layout"]["pos_in_scrolling_layout"][0] += -1 if old < dest else 1
        target["layout"]["pos_in_scrolling_layout"][0] = dest
    else: raise AssertionError(a)
save()
'''


def window(id, app, ws, col, focused=False):
    return {"id": id, "app_id": app, "workspace_id": ws, "is_focused": focused,
            "is_floating": col == 0, "layout": {"pos_in_scrolling_layout": [col, 1] if col else None}}


class SingletonTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name)
        bin_dir = self.path / "bin"
        bin_dir.mkdir()
        (bin_dir / "niri").write_text(FAKE_NIRI)
        (bin_dir / "niri").chmod(0o755)
        self.env = dict(os.environ, PATH=f"{bin_dir}:{os.environ['PATH']}", FAKE_NIRI=str(self.path / "state.json"))

    def run_case(self, windows, focused_ws=10):
        state = {"windows": windows, "workspaces": [{"id": 10, "output": "DP-1", "is_focused": focused_ws == 10}, {"id": 20, "output": "DP-2", "is_focused": focused_ws == 20}], "actions": []}
        Path(self.env["FAKE_NIRI"]).write_text(json.dumps(state))
        result = subprocess.run(["bash", str(SCRIPT), "todo", "false"], env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(Path(self.env["FAKE_NIRI"]).read_text())

    def test_left_to_right(self):
        s = self.run_case([window(1, "editor", 10, 2, True), window(2, "todo", 10, 1)])
        self.assertEqual([col(w) for w in s["windows"]], [1, 2])
        self.assertEqual(s["actions"], [["focus-window", "--id", "2"], ["move-column-to-index", "2"]])

    def test_right_to_adjacent(self):
        s = self.run_case([window(1, "editor", 10, 1, True), window(3, "other", 10, 2), window(2, "todo", 10, 3)])
        self.assertEqual([col(w) for w in s["windows"]], [1, 3, 2])
        self.assertTrue(s["windows"][2]["is_focused"])

    def test_cross_monitor_and_workspace(self):
        s = self.run_case([window(1, "editor", 10, 1, True), window(3, "other", 10, 2), window(2, "todo", 20, 1)])
        self.assertEqual(s["windows"][2]["workspace_id"], 10)
        self.assertEqual([col(w) for w in s["windows"]], [1, 3, 2])
        self.assertEqual(s["actions"][0], ["move-window-to-monitor", "--id", "2", "DP-1"])

    def test_cross_monitor_to_second_output(self):
        s = self.run_case([window(1, "editor", 20, 1, True), window(2, "todo", 10, 1)], focused_ws=20)
        self.assertEqual(s["windows"][1]["workspace_id"], 20)
        self.assertTrue(s["windows"][1]["is_focused"])
        self.assertEqual(s["actions"][0], ["move-window-to-monitor", "--id", "2", "DP-2"])

    def test_stacked_with_anchor(self):
        s = self.run_case([window(1, "editor", 10, 1, True), window(2, "todo", 10, 1), window(3, "other", 10, 2)])
        self.assertEqual([col(w) for w in s["windows"]], [1, 2, 3])
        self.assertEqual(s["actions"][0], ["consume-or-expel-window-right", "--id", "2"])
        self.assertTrue(s["windows"][1]["is_focused"])

    def test_stacked_in_another_column(self):
        s = self.run_case([window(1, "editor", 10, 3, True), window(2, "todo", 10, 1), window(3, "other", 10, 1), window(4, "middle", 10, 2)])
        self.assertEqual([col(w) for w in s["windows"]], [3, 4, 1, 2])
        self.assertEqual(s["actions"][0], ["consume-or-expel-window-right", "--id", "2"])

    def test_floating_target(self):
        s = self.run_case([window(1, "editor", 10, 1, True), window(2, "todo", 10, 0)])
        self.assertEqual(col(s["windows"][1]), 2)
        self.assertEqual(s["actions"][0], ["move-window-to-tiling", "--id", "2"])

    def test_floating_anchor_keeps_target_floating(self):
        s = self.run_case([window(1, "editor", 10, 0, True), window(2, "todo", 10, 0)])
        self.assertTrue(s["windows"][1]["is_floating"])
        self.assertEqual(s["actions"], [["focus-window", "--id", "2"]])

    def test_already_focused(self):
        s = self.run_case([window(2, "todo", 10, 1, True)])
        self.assertEqual(s["actions"], [])

    def test_no_anchor_moves_app_to_current_workspace(self):
        s = self.run_case([window(2, "todo", 20, 1)])
        self.assertEqual(s["windows"][0]["workspace_id"], 10)
        self.assertTrue(s["windows"][0]["is_focused"])
        self.assertEqual(s["actions"], [["move-window-to-monitor", "--id", "2", "DP-1"], ["focus-window", "--id", "2"]])

    def test_no_anchor_to_second_output(self):
        s = self.run_case([window(2, "todo", 10, 1)], focused_ws=20)
        self.assertEqual(s["windows"][0]["workspace_id"], 20)
        self.assertEqual(s["actions"], [["move-window-to-monitor", "--id", "2", "DP-2"], ["focus-window", "--id", "2"]])

    def test_no_anchor_on_same_workspace_does_not_move(self):
        s = self.run_case([window(2, "todo", 10, 1)])
        self.assertEqual(s["actions"], [["focus-window", "--id", "2"]])

    def test_missing_in_niri_launches_app(self):
        state = {"windows": [window(1, "editor", 10, 1, True)], "actions": [], "workspaces": []}
        Path(self.env["FAKE_NIRI"]).write_text(json.dumps(state))
        output = self.path / "output"
        subprocess.run(["bash", str(SCRIPT), "todo", sys.executable, "-c", "import sys;open(sys.argv[1], 'w').write(sys.argv[2])", str(output), "one 'quoted' argument"], env=self.env, check=True)
        self.assertEqual(output.read_text(), "one 'quoted' argument")
        self.assertEqual(json.loads(Path(self.env["FAKE_NIRI"]).read_text())["actions"], [])


def col(win):
    pos = win["layout"]["pos_in_scrolling_layout"]
    return pos[0] if pos else 0


if __name__ == "__main__":
    unittest.main()
