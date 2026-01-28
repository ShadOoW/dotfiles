-- Odin filetype settings
-- Automatically loaded for *.odin buffers

-- Use 2 spaces for Odin files (personal preference over community tabs)
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2

-- Enable syntax highlighting
vim.opt_local.syntax = 'on'

-- Set comment string for Odin
vim.opt_local.commentstring = '// %s'

-- Set up proper indentation
vim.opt_local.smartindent = true
vim.opt_local.autoindent = true

-- Enable spell checking in comments
vim.opt_local.spell = true
vim.opt_local.spelllang = { 'en_us' }

