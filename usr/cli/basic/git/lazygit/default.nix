{ config, ... }: {
  imports = [ ./co-author ];
  cachix_packages = [ config.programs.lazygit.package ];
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        # screenMode = "half";
        mainPanelSplitMode = "horizontal";
        expandFocusedSidePanel = true;
        expandedSidePanelWeight = 4;
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
        ignoreWhitespaceInDiffView = true;
      };
    };
  };
}
