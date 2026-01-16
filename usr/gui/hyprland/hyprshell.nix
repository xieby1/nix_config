# Hyprspace vs hyprshell
# * Hyprspace's display seem buggy in my config
# * Hyprspace's author does not have enough time and recommand user to try niri.
{ pkgs, ... }: {
  services.hyprshell = {
    enable = true;
    package = pkgs.hyprshell.overrideAttrs (final: prev: {
      # https://github.com/H3rmt/hyprshell/issues/372
      src = pkgs.fetchFromGitHub {
        owner = "H3rmt";
        repo = "hyprshell";
        rev = "69011f802ebfd14e710f9cccd6f856ce2e0d4c40";
        hash = "sha256-nemSN4dqwKKTqHyRwFKpEf54PPoHUvhCtrRBvasXEVg=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        src = final.src;
        hash = "sha256-g23W5cgGxWNyJ4uew2x12vgF5Bvaid1+phV2fxyHbas=";
      };
      # Unnecessary due to cargoDeps having higher priority than cargoHash,
      # but to make it explicitly that cargoHash is not used after overrideAttrs.
      cargoHash = null;
    });
  };
}
