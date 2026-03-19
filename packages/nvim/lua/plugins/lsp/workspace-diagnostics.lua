-- workspace-diagnostics.nvim
-- Sends textDocument/didOpen for all git-tracked project files to the LSP so
-- the server pushes diagnostics for files you haven't opened yet.
-- This makes <leader>xd show project-wide errors, not just open buffers.
return {
  'artemave/workspace-diagnostics.nvim',
  lazy = true, -- loaded on demand from lsp/handlers.lua on_attach
}
