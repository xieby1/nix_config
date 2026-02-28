{ pkgs, ... }: let
  # /*lang*//* content... */
  gen_c_style_query = node-name: set-lang: /*query*/''
    ; extends
    (
      (${node-name}) @injection.language
      (#lua-match? @injection.language "/%*[%w%p]+%*/")
      .
      (${node-name}) @injection.content
      (#lua-match? @injection.content "/%*.*%*/")
      (#offset! @injection.content 0 2 0 -2)
      (#gsub! @injection.language "/%*([%w%p]+)%*/" "${if set-lang then "%1" else ""}")
      (#set! injection.combined)
    )
  '';
in {
  programs.neovim = {
    # TODO: simplify
    extraLuaConfig = /*lua*/ ''
      _G.enable_rust_doccom_injection = function()
        vim.treesitter.query.set("rust", "injections", [[
          ${gen_c_style_query "block_comment" true}
        ]])
      end
      _G.disable_rust_doccom_injection = function()
        vim.treesitter.query.set("rust", "injections", [[
          ${gen_c_style_query "block_comment" false}
        ]])
      end
      _G.enable_typst_doccom_injection = function()
        vim.treesitter.query.set("typst", "injections", [[
          ${gen_c_style_query "comment" true}
        ]])
      end
      _G.disable_typst_doccom_injection = function()
        vim.treesitter.query.set("typst", "injections", [[
          ${gen_c_style_query "comment" false}
        ]])
      end
    '';
  };
}
