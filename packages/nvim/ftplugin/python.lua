-- Python filetype settings
-- Auto-loaded for *.py buffers. Built-in python.vim sets PEP 8 indent, commentstring, etc.
-- PEP 8: 4 spaces (built-in sets this; override if needed)
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4

vim.opt_local.syntax = 'on'
vim.opt_local.commentstring = '# %s'

vim.opt_local.smartindent = true
vim.opt_local.autoindent = true

-- Spell in comments and docstrings
vim.opt_local.spell = true
vim.opt_local.spelllang = { 'en_us' }

-- Black default line length
vim.opt_local.textwidth = 88

vim.opt_local.wrap = false

-- Help gf / includeexpr find Python modules
vim.opt_local.suffixesadd = '.py'

-- K opens pydoc for word under cursor
if vim.fn.executable('python3') == 1 then
  vim.opt_local.keywordprg = 'python3 -m pydoc'
elseif vim.fn.executable('python') == 1 then
  vim.opt_local.keywordprg = 'python -m pydoc'
end
