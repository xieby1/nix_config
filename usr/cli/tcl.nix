{ config, pkgs, stdenv, lib, ... }:
let
  # inspired by https://stackoverflow.com/questions/73542495/writing-to-file-descriptor-0-stdin-only-affects-terminal-program-doesnt-read
  ioctl = pkgs.writeCBin "ioctl" ''
    #include <sys/ioctl.h> /* ioctl */
    #include <stdio.h> /* printf, perror */
    #include <fcntl.h> /* open */
    #include <errno.h> /* errno */
    #include <unistd.h> /* close */

    int main(int argc, char **argv) {
        int fd;
        char* input;
        if (argc == 3) {
            fd = open(argv[1], O_RDWR);
            if (fd < 0) {
                perror("Failed to open fd");
                return errno;
            }
            input = argv[2];
        } else {
            printf("Usage: %s <path to stdin> <input>\n",
                    argv[0]);
            return 1;
        }

        for (int i=0; input[i]!='\0'; i++) {
            int res = ioctl(fd, TIOCSTI, input+i);
            if (res < 0) {
                perror("ioctl");
                close(fd);
                return errno;
            }
        }
        close(fd);

        return 0;
    }
  '';
in {
  home.packages = with pkgs; [
    tcl
    # enable readline
    ## https://stackoverflow.com/questions/35819022/how-to-use-the-left-and-right-arrow-keys-in-the-tclsh-interactive-shell-ubuntu
    #rlwrap
    tclreadline
    tclx
  ];

  # see https://github.com/flightaware/tclreadline/blob/master/sample.tclshrc
  home.file.tclshrc = {
    text = let
      u_red   = "\\[01;31m";
      u_blue  = "\\[01;34m";
      u_green = "\\[01;32m";
      u_white = "\\[00m";
    in ''
      # ignore ctrl-c
      ## https://comp.lang.tcl.narkive.com/WnpY54UP/disabling-ignoring-ctrl-c
      if {$tcl_interactive} {
        package require Tclx
        package require tclreadline

        # tclreadline's fancy ls proc
        namespace import tclreadline::ls

        # based on <nixpkgs.tclreadline>/lib/tclreadline2.3.8/tclreadlineSetup.tcl
        namespace eval ::tclreadline {
            variable prompt_string
            set base [file tail [info nameofexecutable]]

            if {[string match tclsh* $base] && [info exists tcl_version]} {
                set prompt_string "${u_green}tclsh$tcl_version${u_white}"
            } elseif {[string match wish* $base] && [info exists tk_version]} {
                set prompt_string "${u_blue}wish$tk_version${u_white}"
            } else {
                set prompt_string "${u_green}$base${u_white}"
            }
        }

        proc ::tclreadline::prompt1 {} {
            variable prompt_string
            global env
            if {[catch {set pwd [pwd]} tmp]} {
                set pwd "unable to get pwd"
            }

            if {[info exists env(HOME)]} {
                variable normalized_home
                if {![info exists normalized_home]} {
                    set normalized_home [file normalize $env(HOME)]
                }
                if {[string equal -length [string length $normalized_home] $pwd $normalized_home]} {
                    set pwd "~[string range $pwd [string length $normalized_home] end]"
                }
            }
            return "$prompt_string:${u_blue}$pwd\n${u_green}> ${u_white}"
        }
    '' + (pkgs.lib.optionalString (config.home.username != "nix-on-droid") ''
        signal -restart trap SIGINT {
          puts -nonewline stdout "^C\n[::tclreadline::prompt1]"
          exec ${ioctl}/bin/ioctl /proc/self/fd/0 "\[H"
        }
    '') + ''
        ::tclreadline::Loop
      }
    '';
    target = ".tclshrc";
  };
}
