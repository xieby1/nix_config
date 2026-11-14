{ lib }: {
  isNixOnDroid = (builtins.getEnv "USER") == "nix-on-droid";

  ai = import ./ai { inherit lib; };
}
