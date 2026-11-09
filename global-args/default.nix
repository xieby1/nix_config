{ lib }: rec {
  isNixOnDroid = (builtins.getEnv "USER") == "nix-on-droid";

  # Though (import ./npins) is callable and can serve as `npinsFun`,
  # I want `npinsFun` to be clean, without other attributes mixed in.
  # TODO: move npins/ to subfolder
  npinsFun = (import ../npins).__functor null;

  ai = import ./ai { inherit lib npinsFun; };
}
