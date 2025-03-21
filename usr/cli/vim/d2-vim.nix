#MC # d2-vim: D2 drawing language
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [( pkgs.vimUtils.buildVimPlugin {
      name = "d2-vim";
      src = pkgs.fetchFromGitHub {
        owner = "terrastruct";
        repo = "d2-vim";
        rev = "981c87dccb63df2887cc41b96e84bf550f736c57";
        hash = "sha256-+mT4pEbtq7f9ZXhOop3Jnjr7ulxU32VtahffIwQqYF4=";
      };
    })];
  };
}
