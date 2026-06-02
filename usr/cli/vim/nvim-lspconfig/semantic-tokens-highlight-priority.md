# LSP semantic-token highlight priority vs Treesitter / todo-comments.nvim

## Problem

Neovim applies multiple highlight sources with different priorities. In the current Neovim runtime, the relevant defaults are:

```lua
vim.hl.priorities = {
  syntax = 50,
  treesitter = 100,
  semantic_tokens = 125,
  diagnostics = 150,
  user = 200,
}
```

This means LSP semantic-token highlights, such as:

```text
@lsp.type.comment
@lsp.type.comment.typst
@lsp.type.variable
@lsp.type.function
```

can override Treesitter highlights because LSP semantic tokens use priority `125`, while Treesitter uses priority `100`.

A practical symptom is that TODO/FIXME comment highlighting can be visually overridden by LSP comment semantic tokens. This is especially noticeable when the server classifies comment text as `@lsp.type.comment.<ft>`.

## What `semanticTokens` means

`semanticTokens` is an LSP capability where the language server sends semantic classifications for source-code tokens. Unlike Treesitter, which is syntax/parser based, semantic tokens can include information from language analysis, such as:

- local variable vs field/property
- function vs method
- type/class/interface/struct
- deprecated, readonly, async, default-library modifiers

In Neovim these become `@lsp.*` highlight groups.

Disabling semantic tokens only affects this semantic-token stream and its derived highlights. Normal LSP features such as diagnostics, hover, completion, goto-definition, references, rename, formatting, code actions, and inlay hints are separate features.

## Solutions

### 1. Clear only LSP comment semantic highlights

This is the most targeted fix when the conflict is in comments/TODOs.

```lua
vim.api.nvim_set_hl(0, "@lsp.type.comment", {})
```

For one filetype only:

```lua
vim.api.nvim_set_hl(0, "@lsp.type.comment.typst", {})
```

Use a `ColorScheme` autocmd so the setting survives colorscheme reloads:

```lua
local function clear_lsp_comment_highlight()
  vim.api.nvim_set_hl(0, "@lsp.type.comment", {})
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = clear_lsp_comment_highlight,
})

clear_lsp_comment_highlight()
```

Pros:

- Keeps useful LSP semantic highlighting for variables/functions/types.
- Removes the low-value LSP comment override.
- Good default if Treesitter should own comment highlighting.

Cons:

- Only solves comment-related conflicts.

### 2. Lower global LSP semantic-token priority

Make semantic tokens lower priority than Treesitter:

```lua
vim.hl.priorities.semantic_tokens = 95
```

Pros:

- Treesitter wins globally.
- Simple and central.

Cons:

- All LSP semantic-token highlights become lower priority, not just comments.
- Some useful LSP distinctions may become visually hidden by Treesitter.

### 3. Disable semantic tokens in default LSP client capabilities

Tell servers that the client does not support semantic tokens:

```lua
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.semanticTokens = nil

vim.lsp.config("*", {
  capabilities = capabilities,
})
```

This should be configured before `vim.lsp.enable(...)` calls.

Pros:

- Cleanly avoids LSP semantic-token traffic and highlights.
- Keeps normal LSP functionality.

Cons:

- Removes all LSP semantic-token-based highlighting and token-update hooks.
- Server-specific configs may override capabilities.
- Some servers may still advertise semantic tokens despite client capabilities, so this is less forceful than changing server capabilities on attach.

### 4. Disable semantic tokens after attach

Force-disable the server capability once the server attaches:

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})
```

For a single server:

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "tinymist" then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})
```

Pros:

- More forceful than client capabilities.
- Useful when a server still provides semantic tokens despite capability changes.

Cons:

- Broader than necessary if the only conflict is comment/TODO highlighting.
- Runs after attach rather than as an initialization preference.

### 5. Ensure todo-comments.nvim is actually configured

Installed `todo-comments.nvim` uses extmarks with priority `500` for its own highlights:

```lua
vim.api.nvim_buf_set_extmark(buf, ns, line, from, {
  end_col = to,
  hl_group = hl,
  priority = 500,
})
```

So if `todo-comments.nvim` is properly set up, its own TODO/FIXME highlights should win over LSP semantic tokens at priority `125`.

Minimal setup:

```lua
require("todo-comments").setup({})
```

If TODO/FIXME highlights are only coming from Treesitter captures at priority `100`, LSP semantic tokens can override them. In that case, explicitly setting up `todo-comments.nvim` may be enough.

Pros:

- Lets todo-comments.nvim own TODO/FIXME highlighting with priority `500`.
- Does not require disabling semantic tokens.

Cons:

- Only addresses TODO/FIXME-style highlights, not other Treesitter vs LSP conflicts.

## Recommended approach

For the TODO/FIXME comment-highlight conflict, prefer this order:

1. Ensure `todo-comments.nvim` is explicitly configured with `require("todo-comments").setup({})`.
2. Clear LSP comment semantic highlights:

   ```lua
   vim.api.nvim_set_hl(0, "@lsp.type.comment", {})
   ```

3. Only if broader conflicts remain, lower `vim.hl.priorities.semantic_tokens` or disable semantic tokens globally.

This preserves useful LSP semantic information for code symbols while letting Treesitter/todo-comments.nvim own comment highlighting.
