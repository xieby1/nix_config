{ config, pkgs, stdenv, lib, ... }:
{
  home.packages = with pkgs; [
    tcl
    # enable readline
    ## https://stackoverflow.com/questions/35819022/how-to-use-the-left-and-right-arrow-keys-in-the-tclsh-interactive-shell-ubuntu
    #rlwrap
    tclreadline
    tclx
  ];

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
        # TODO: xdotool is too slow
        signal -restart trap SIGINT {
            exec xdotool key --clearmodifiers "Home"
            exec xdotool key --clearmodifiers "ctrl+k"
            exec xdotool key --clearmodifiers "Enter"
        }

        package require tclreadline

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

        ::tclreadline::Loop

        package require Tclx
        signal -restart trap SIGINT {puts stderr "signal %S received}
      }
    '';
    target = ".tclshrc";
  };
}
