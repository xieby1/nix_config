{ pkgs, ... }: let
  forgecode = (pkgs.flake-compat {src = pkgs.npinsed.ai.forgecode;}).defaultNix.default
    # The version and APP_VERSION is 0.1.0-dev, which is out-of-date
    .overrideAttrs (_old: rec {
      # Forge skips update checks when version contains "dev", avoiding prompts like:
      # `Confirm upgrade from v2.9.9 -> v2.10.0 (latest)? Y/n:`
      # See: crates/forge_main/src/update.rs
      version = "${pkgs.npinsed.ai.forgecode.version}-dev";
      APP_VERSION=version;
      __intentionallyOverridingVersion=true;
    });
in {
  home.packages = [ forgecode ];
  cachix_packages = [ forgecode ];
}
