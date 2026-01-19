{ pkgs, config, ... }: let
  # TODO: use kitty --class
  open_my_cheatsheet_md_sh = pkgs.writeShellScript "open_my_cheatsheet_md" ''
    cd ${config.home.homeDirectory}/Documents/Tech
    # Open Outline and focus on code
    kitty nvim my_cheatsheet.mkd -c Outline!
    if [[ ! -f my_cheatsheet.html || my_cheatsheet.html -ot my_cheatsheet.mkd ]]; then
      ~/Codes/MyRepos/markdown_cheatsheet/cheatsheet.sh my_cheatsheet.mkd
    fi
  '';
in {
  xdg.desktopEntries = {
    # singleton apps
    my_cheatsheet_md = {
      name = "Cheatsheet Edit MD";
      genericName = "cheatsheet";
      exec = "${open_my_cheatsheet_md_sh}";
      icon = builtins.toFile "cheatsheet.svg" ''
        <svg width="64" height="64" xmlns="http://www.w3.org/2000/svg">
          <rect width="100%" height="100%" rx="20%" ry="20%" fill="#666666"/>
          <text x="50%" y="50%" text-anchor="middle" dominant-baseline="middle" font-size="18" font-weight="bold" fill="#F5F5F5">
            <tspan x="50%" dy="-1.0em">CS</tspan>
            <tspan x="50%" dy="1.0em">Edit</tspan>
            <tspan x="50%" dy="1.0em">MD</tspan>
          </text>
        </svg>
      '';
    };
  };
}

