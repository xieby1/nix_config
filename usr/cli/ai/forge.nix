{ pkgs, ... }: let
  forgecode = (pkgs.flake-compat {src = pkgs.npinsed.forgecode;}).defaultNix.default
    # The version and APP_VERSION is 0.1.0-dev, which is out-of-date
    .overrideAttrs (_old: rec {
      inherit (pkgs.npinsed.forgecode) version;
      APP_VERSION=version;
      __intentionallyOverridingVersion=true;
    });
in {
  home.packages = [ forgecode ];
  cachix_packages = [ forgecode ];
}
