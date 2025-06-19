-- LSP plugins
return {
  require('plugins.lsp.diagnostics-cmd'),
  require('plugins.lsp.diagnostics'),
  require('plugins.lsp.conform'),
  require('plugins.lsp.lazydev'),
  require('plugins.lsp.nvim-lspconfig'),
  require('plugins.lsp.mason'),
  require('plugins.lsp.mason-tool-installer'),
  require('plugins.lsp.servers'),
}
