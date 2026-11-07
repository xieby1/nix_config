#!/usr/bin/env bash
cachix -c ~/Gist/Config/cachix.dhall push xieby1 $(nix-build $(dirname $(realpath $0))/default.nix)
