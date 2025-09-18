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
      init.defaultBranch = "main";
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
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        screenMode = "half";
        mainPanelSplitMode = "horizontal";
        commitAuthorLongLength = builtins.stringLength "xieby1";

        # https://pkg.go.dev/time#Time.Format
        # Year: "2006" "06"
        # Month: "Jan" "January" "01" "1"
        # Day of the week: "Mon" "Monday"
        # Day of the month: "2" "_2" "02"
        # Day of the year: "__2" "002"
        # Hour: "15" "3" "03" (PM or AM)
        # Minute: "4" "04"
        # Second: "5" "05"
        # AM/PM mark: "PM"
        timeFormat = "2006.01.02";
        shortTimeFormat = "15:04";
      };
      keybinding = {
        universal = {
          rangeSelectDown = "";
          rangeSelectUp = "";
          scrollUpMain-alt1 = "<s-up>";
          scrollDownMain-alt1 = "<s-down>";
        };
      };
      promptToReturnFromSubprocess = false;
      git = {
        autoFetch = false;
      };
    };
  };
}
