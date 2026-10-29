# The cgit this tree serves and installs.
#
# The repolist "Idle" column stats refs/heads/<defbranch> and hardcodes
# "master" as the default; repos found by scan-path never get a defbranch, so a
# repo whose HEAD is main was reported as idle since the last gc (the
# packed-refs mtime) however recently it was pushed to. The patch follows HEAD.
#
# Single source for the web route, home.packages and the route test: a second,
# unpatched cgit in the profile would show the old numbers when run by hand.
# shortcut: patch touches ui-repolist.c only; re-check when cgit is bumped.
{ pkgs }:
pkgs.cgit.overrideAttrs (prev: {
  patches = (prev.patches or [ ]) ++ [ ./cgit-idle-follow-head.patch ];
})
