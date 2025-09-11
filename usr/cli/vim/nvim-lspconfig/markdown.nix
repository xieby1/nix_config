{ pkgs, ... }: {
  # markdown lsp candidates:
  # * marksman
  #   * keeps throwing errors: MailboxProcessor.PostAndAsyncReply timed out.
  #     Which is marked solved by author in 2023
  #     * https://github.com/artempyanykh/marksman/issues/144
  #     * https://github.com/artempyanykh/marksman/issues/164
  #     Really solved?
  #     Martins3 reports this problem on aarch64
  #     * https://github.com/Martins3/My-Linux-Config/issues/180
  #     Recent same bug report: during heading editing:
  #     * https://github.com/artempyanykh/marksman/issues/408
  #   * Maybe this MailboxProcessor.PostAndAsyncReply bug only comes out in LARGE documents folder?
  # * zk: no goto def support
  # * markdown-oxide: https://oxide.md/Features+Index
  #   * no goto link support
  #   * no completion of headings in the current file
  #   * ...
  programs.neovim = {
    extraLuaConfig = ''
      require('lspconfig').marksman.setup {}
    '';
    extraPackages = [(
      pkgs.marksman
    )];
  };
}
