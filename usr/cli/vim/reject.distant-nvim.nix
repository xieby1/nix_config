#MC # distant-nvim: edit remote files with local nvim
#MC
#MC 不足:
#MC * 文档不在源码里，没有:h
#MC * 文档写的很不清晰，找了半天才知道:DistantConnect和:DistantOpen
#MC * 现有nvim文件操作似乎都不能用，比如:Ex比如<leader>ff等，都需要用它的:DistantOpen
#MC * 简单尝试了xiangshan项目的跳转，没办法正常使用。但是sshfs一切正常
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.pkgsu.vimPlugins.distant-nvim;
      type = "lua";
      config = ''
        require('distant'):setup()
      '';
    }];
    extraPackages = [
      pkgs.pkgsu.distant
    ];
  };
}
