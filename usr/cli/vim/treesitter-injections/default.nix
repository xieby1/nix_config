{ pkgs, ... }: let
  # /*lang*//* content... */
  gen_c_style_query = node: set-lang: /*query*/''
    ; extends
    (
      (${node}) @injection.language
      (#lua-match? @injection.language "/%*[%w%p]+%*/")
      .
      (${node}) @injection.content
      (#lua-match? @injection.content "/%*.*%*/")
      (#offset! @injection.content 0 2 0 -2)
      (#gsub! @injection.language "/%*([%w%p]+)%*/" "${if set-lang then "%1" else ""}")
      (#set! injection.combined)
    )
  '';
  gen_c_style_toggle_fn = lang: node: /*lua*/ ''function()
    if _G.${lang}_doccom_injection_enabled then
      vim.treesitter.query.set("${lang}", "injections", [[${gen_c_style_query node false}]])
      _G.${lang}_doccom_injection_enabled = false
    else
      vim.treesitter.query.set("${lang}", "injections", [[${gen_c_style_query node true}]])
      _G.${lang}_doccom_injection_enabled = true
    end
    -- refresh current buffer
    vim.cmd("e")
  end'';
in {
  programs.neovim = {
    # TODO: simplify
    extraLuaConfig = /*lua*/ ''
      _G.toggle_rust_doccom_injection = ${gen_c_style_toggle_fn "rust" "block_comment"}
      _G.toggle_typst_doccom_injection = ${gen_c_style_toggle_fn "typst" "comment"}
    '';
  };
}
