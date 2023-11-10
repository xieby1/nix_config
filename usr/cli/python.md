# Python in Nix/NixOS

<div style="text-align:right; font-size:3em;">2023.05.03</div>

| Project              | Maintained | Description | Purity | Compatibility |
|----------------------|------------|-------------|--------|---------------|
| venv                 |            |             | ❌     | 100%?         |
| mach-nix             | ✅         |             |        |               |
| pypi2nix             | ❌         |             |        |               |
| pip2nix              | ✅         |             | ✅     |               |
| `buildPythonPackage` | ✅         |             | ✅     |               |
| [TODO] poetry        |            |             |        |               |
| [TODO] dream2nix     |            |             |        |               |

## pip2nix

Noted: Latest version of pip2nix only use python39.
While nixpkgs 22.11 (current stable) is python310.
I dont to install multiple versions of python3.

If pip2nix can overcome the disadvantage of that
generate a long list of python packages,
and reuse python3Packages in nixpkgs,
I would prefer to use pip2nix completely.

Currently, I use `buildPythonPackage`.

## `buildPythonPackage`

`pkgs.python3Packages.buildPythonPackage`

## venv

Use virtualenv, `pip` is available, no need to write nix expressions to install packages.

Code see https://xieby1.github.io/scripts/index.html#venvnix

## poetry

<div style="text-align:right; font-size:3em;">2022.05.15</div>

According to [What is the correct way to setup pip with nix to install any python package in an isolated nix environment](https://www.reddit.com/r/NixOS/comments/q71v0e/what_is_the_correct_way_to_setup_pip_with_nix_to/),
I found two useful tools to install python packages in Nix/NixOS

* [TODO] poetry
* mach-nix

## mach-nix

mach-nix github repo:
[github.com/DavHau/mach-nix](https://github.com/DavHau/mach-nix)

Here is [python_mach.nix]({{ site.repo_url }}/scripts/shell/python_mach.nix),
an example which create a shell with a python package called expmcc.
