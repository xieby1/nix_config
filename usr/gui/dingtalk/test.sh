#!/usr/bin/env bash
# DingTalk's screen share dies silently when the preloaded wayland hook is built
# against a different glibc than the system binaries it gets loaded into: the
# hook then never runs in the conference process (`tblive`), so no portal
# screencast starts and the display picker never appears. Re-pointing dingtalk
# at `pkgs.nur.repos.yakkhini.dingtalk` (built from pkgsu, glibc 2.44) does
# exactly that while still evaluating and starting fine, hence this check.
set -euo pipefail
fail() {
  echo "FAIL: $1"
  exit 1
}

dingtalk=$(readlink -f "$(command -v dingtalk || true)")
if [ -z "$dingtalk" ]; then
  echo "skip: dingtalk is not installed here"
  exit 0
fi

hook=$(grep -aoE "/nix/store/[a-z0-9]+-dingtalk-wayland-screenshare-[^/]*/lib/libdingtalkhook\.so" "$dingtalk" | head -1)
[ -n "$hook" ] || fail "$dingtalk does not preload libdingtalkhook.so"

hook_glibc=$(nix-store -qR "$hook" | grep -oE "/nix/store/[a-z0-9]+-glibc-[0-9.]+" | head -1)
system_glibc=$(ldd /bin/sh | grep -oE "/nix/store/[a-z0-9]+-glibc-[0-9.]+" | head -1)
[ -n "$hook_glibc" ] || fail "cannot find the hook's glibc"
[ -n "$system_glibc" ] || fail "cannot find the system glibc"
[ "$hook_glibc" = "$system_glibc" ] || fail "hook uses $hook_glibc but the system uses $system_glibc"

echo "ok: the screen-share hook and the system share $hook_glibc"
