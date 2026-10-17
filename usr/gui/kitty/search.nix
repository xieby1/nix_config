{ pkgs, ... }: let
  kitty-kitten-search = pkgs.runCommand "kitty-kitten-search" {
    src = pkgs.fetchFromGitHub {
      owner = "trygveaa";
      repo = "kitty-kitten-search";
      rev = "0760138fad617c5e4159403cbfce8421ccdfe571";
      hash = "sha256-egisza7V5dWplRYHIYt4bEQdqXa4E7UhibyWJAup8as=";
    };
  } ''
    mkdir $out
    cp $src/scroll_mark.py $out/scroll_mark.py
    sed 's/typing/typing_compat/' $src/search.py > $out/search.py
  '';
in {
  home.file.kitty_search = {
    source = "${kitty-kitten-search}/search.py";
    target = ".config/kitty/search.py";
  };
  home.file.kitty_scroll_mark = {
    source = "${kitty-kitten-search}/scroll_mark.py";
    target = ".config/kitty/scroll_mark.py";
  };
  programs.kitty = {
    extraConfig = ''
      map ctrl+shift+f launch --location=hsplit --allow-remote-control kitty +kitten search.py @active-kitty-window-id
    '';
  };
}
