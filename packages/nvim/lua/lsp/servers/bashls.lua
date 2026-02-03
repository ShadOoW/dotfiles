-- Bash LSP server configuration
return {
  filetypes = { 'sh', 'bash' },
  single_file_support = true,
  on_attach = function(client, bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    -- Detach from .env files to avoid "unused variable" warnings
    if filename:match('%.env$') or filename:match('%.env%.') then
      client.stop()
      return
    end
    -- Fallback to common on_attach
    require('lsp.handlers').on_attach(client, bufnr)
  end,
}
