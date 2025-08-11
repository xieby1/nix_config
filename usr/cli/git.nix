{ pkgs, ... }: let
  git-wip = builtins.derivation {
    name = "git-wip";
    system = builtins.currentSystem;
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/bartman/git-wip/1c095e93539261370ae811ebf47b8d3fe9166869/git-wip";
      sha256 = "00gq5bwwhjy68ig26a62307pww2i81y3zcx9yqr8fa36fsqaw37h";
    };
    builder = pkgs.writeShellScript "git-wip-builder" ''
      source ${pkgs.stdenv}/setup
      mkdir -p $out/bin
      dst=$out/bin/git-wip
      cp $src $dst
      chmod +w $dst
      sed -i 's/#!\/bin\/bash/#!\/usr\/bin\/env bash/g' $dst
      chmod -w $dst
      chmod a+x $dst
    '';
  };
in {
  home.packages = with pkgs; [
    gitui
    lazygit
    mr
    git-wip
    git-quick-stats
  ];
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userEmail = "xieby1@outlook.com";
    userName = "xieby1";
    extraConfig = {
      core = {
        editor = "vim";
      };
      credential.helper = "store";
    };
    aliases = {
      viz = "log --all --decorate --oneline --graph";
    };
    lfs.enable = true;
  };
  systemd.user.tmpfiles.rules = [
    "L? %h/.mrconfig - - - - %h/Gist/Config/mrconfig"
  ];
  # mr status not work in non-home dir
  programs.bash.shellAliases.mr = "mr -d ~";
}
