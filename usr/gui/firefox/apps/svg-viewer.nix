{ pkgs, ... }: let
  name = "firefox-svg-viewer";
in {
  firefox-apps = [{
    inherit name;
    url = "";
    icon = builtins.toFile "${name}.svg" ''
      <svg width="64" height="64" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" rx="20%" ry="20%" fill="white"/>
        <text x="50%" y="50%" text-anchor="middle" dominant-baseline="middle" font-size="14" font-weight="bold" fill="#6155d2">
          <tspan x="50%" dy="-1em">Firefox</tspan>
          <tspan x="50%" dy="1em">SVG</tspan>
          <tspan x="50%" dy="1em">Viewer</tspan>
        </text>
      </svg>
    '';
  }];

  home.packages = map (n: (
    pkgs.writeScriptBin n ''
      firefox -P ${name} --class ${name} "$@"
    ''
  )) [name "svg-viewer"];
}
