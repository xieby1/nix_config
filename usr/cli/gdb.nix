#MC # GDB configurations
{ pkgs, ... }: {
  home.packages = [
    pkgs.gdb
  ];
  home.file.gdbinit = {
    source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/cyrus-and/gdb-dashboard/2b107b27949d13f6ef041de6eec1ad2e5f7b4cbf/.gdbinit";
      sha256 = "02rxyk8hmk7xk1pyhnc5z6a2kqyd63703rymy9rfmypn6057i4sr";
      name = "gdbinit";
    };
    target = ".gdbinit";
  };
  home.file.gdb_dashboard_init = {
    text = ''
      # gdb-dashboard init file

      # available layout modules
      #   stack registers history assembly
      #   breakpoints expressions memory
      #   source threads variables
      dashboard -layout source

      # https://en.wikipedia.org/wiki/ANSI_escape_code
      #dashboard -style prompt
      ## fg bold blue
      dashboard -style prompt_not_running "\\[\\e[1;34m\\]$\\[\\e[0m\\]"
      ## fg bold green
      dashboard -style prompt_running "\\[\\e[1;32m\\]$\\[\\e[0m\\]"
    '';
    target = ".gdbinit.d/init";
  };
}
