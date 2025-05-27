-- Keymaps configuration
local keymap = require("utils.keymap")

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
keymap.n('<Esc>', '<cmd>nohlsearch<CR>', 'Clear search highlights')

-- Diagnostic keymaps
keymap.n('<leader>q', vim.diagnostic.setloclist, 'Open diagnostic [Q]uickfix list')

-- Window navigation with Tab and Shift+Tab
keymap.n('<Tab>', '<C-w>w', 'Cycle to next window')
keymap.n('<S-Tab>', '<C-w>W', 'Cycle to previous window')

-- Move windows around
keymap.n("<C-S-h>", "<C-w>H", "Move window to the left")
keymap.n("<C-S-l>", "<C-w>L", "Move window to the right")
keymap.n("<C-S-j>", "<C-w>J", "Move window to the bottom")
keymap.n("<C-S-k>", "<C-w>K", "Move window to the top")

-- Telescope keymaps
keymap.n("<leader>ff", "<cmd>Telescope find_files<cr>", "File Operations")

-- Buffer navigation
keymap.n("<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
keymap.n("<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
keymap.n("<leader>bp", "<cmd>BufferLinePick<cr>", "Pick buffer")
keymap.n("<leader>bc", "<cmd>BufferLinePickClose<cr>", "Pick and close buffer")
keymap.n("<M-~>", ":BufferLineCycleNext<CR>", "Next buffer tab")
keymap.n("<M-S-~>", ":BufferLineCyclePrev<CR>", "Previous buffer tab")
-- Buffer navigation with leader+arrow keys
keymap.n("<leader><Right>", "<cmd>bnext<CR>", "Next buffer")
keymap.n("<leader><Left>", "<cmd>bprevious<CR>", "Previous buffer")

-- Comment keymaps
keymap.n("<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<cr>", "Toggle comment")
keymap.v("<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", "Toggle comment")

-- LSP keymaps
keymap.n("K", "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover documentation")
keymap.n("<leader>aa", "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code action")
keymap.n("<leader>ar", "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename symbol")

-- Indentation in visual mode
keymap.v("<", "<gv", "Outdent line")
keymap.v(">", ">gv", "Indent line")

-- Move lines up and down
keymap.v("J", ":m '>+1<CR>gv=gv", "Move selection down")
keymap.v("K", ":m '<-2<CR>gv=gv", "Move selection up")

-- Search and replace current word
keymap.n("<leader>sr", ":%s/<C-r><C-w>//g<Left><Left>", "Search and replace word under cursor")
