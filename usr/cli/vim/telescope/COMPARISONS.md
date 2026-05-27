# Telescope Alternatives Comparison

Brief notes from debugging Telescope `find_files`, `live_grep_args`, symlink following, and runtime backend args.

## Telescope

- `find_files` uses external file listing commands (`rg --files`, `fd`, or `find`) and Telescope/fzf-native only sorts/filter results.
- `find_files` supports launch-time options such as `follow`, `hidden`, `no_ignore`, `no_ignore_parent`, and `find_command`.
- `live_grep_args.nvim` supports prompt-time args for grep/content search, but not file search.
- No mature general Telescope solution was found for prompt-time backend args across both file search and grep.
- In-picker toggles for follow/hidden/ignored are not native; use separate keymaps or write a custom picker.

## Snacks picker

- Best match for a unified modern picker with runtime behavior.
- Docs say `files` and `grep` support adding backend options in the prompt, e.g. `foo -- -e=lua`.
- Has built-in interactive toggles:
  - `<C-f>`: follow symlinks
  - `<C-h>`: hidden files
  - `<C-i>`: ignored files
  - `<C-r>`: regex
  - `<C-l>`: live mode
- Strong candidate if interactive file/grep args and toggles matter more than staying on Telescope.

## fzf-lua

- Strong Telescope replacement if real fzf behavior is desired.
- Has file and grep pickers with configurable `fd`/`rg` options.
- File picker supports interactive toggles such as:
  - `alt-f`: follow
  - `alt-h`: hidden
  - `alt-i`: ignore
- Less directly a unified prompt-args abstraction than Snacks, but very capable.

## Recommendation

- Stay on Telescope for minimal disruption; add launch-time keymap variants for common modes.
- Try Snacks picker first if the goal is unified file/grep runtime args plus in-picker toggles.
- Try fzf-lua if the goal is a fast fzf-centered Telescope replacement.
