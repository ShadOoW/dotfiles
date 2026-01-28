-- Dart / Flutter filetype settings
-- Automatically loaded for *.dart buffers

-- Use 2 spaces for Dart files (Flutter/Dart convention)
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2

-- Enable syntax highlighting
vim.opt_local.syntax = 'on'

-- Set comment string for Dart
vim.opt_local.commentstring = '// %s'

-- Set up proper indentation
vim.opt_local.smartindent = true
vim.opt_local.autoindent = true

-- Enable spell checking in comments
vim.opt_local.spell = true
vim.opt_local.spelllang = { 'en_us' }

-- Text width for Dart (Dart style guide recommends 80)
vim.opt_local.textwidth = 80

-- Disable wrapping for long lines (prefer horizontal scrolling)
vim.opt_local.wrap = false

-- Better folding for Flutter widget trees
vim.opt_local.foldmethod = 'syntax'
vim.opt_local.foldlevel = 99

