return {
  filetypes = { 'python' },
  -- ruff reads config from pyproject.toml / ruff.toml / .ruff.toml automatically.
  on_attach = function(client, bufnr)
    require('lsp.handlers').on_attach(client, bufnr)
    -- Ruff's hover is inferior to basedpyright's — disable it so basedpyright wins.
    client.server_capabilities.hoverProvider = false
    -- Formatting is handled by conform (ruff CLI), not via LSP protocol.
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
