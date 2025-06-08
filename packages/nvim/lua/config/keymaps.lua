-- Keymaps configuration
local keymap = require('utils.keymap')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
keymap.n('<Esc>', '<cmd>nohlsearch<CR>', 'Clear search highlights')

-- Diagnostic keymaps
keymap.n('<leader>q', vim.diagnostic.setloclist, 'Open diagnostic [Q]uickfix list')

-- Unified split commands (matching tmux)
keymap.n('<C-M-v>', '<cmd>vsplit<CR>', 'Split window vertically (unified)')
keymap.n('<C-M-s>', '<cmd>split<CR>', 'Split window horizontally (unified)')

-- Move windows around
keymap.n('<C-S-h>', '<C-w>H', 'Move window to the left')
keymap.n('<C-S-l>', '<C-w>L', 'Move window to the right')
keymap.n('<C-S-j>', '<C-w>J', 'Move window to the bottom')
keymap.n('<C-S-k>', '<C-w>K', 'Move window to the top')

-- Telescope keymaps
keymap.n('<leader>fq', '<cmd>Bd<cr>', 'Close file (preserve split)')
keymap.n('<leader>fw', '<cmd>write<cr>', 'Write file')

-- Buffer navigation
keymap.n('<S-h>', '<cmd>BufferLineCyclePrev<cr>', 'Previous buffer')
keymap.n('<S-l>', '<cmd>BufferLineCycleNext<cr>', 'Next buffer')
keymap.n('<leader>bp', '<cmd>BufferLinePick<cr>', 'Pick buffer')
keymap.n('<leader>bc', '<cmd>BufferLinePickClose<cr>', 'Pick and close buffer')
keymap.n('<M-~>', ':BufferLineCycleNext<CR>', 'Next buffer tab')
keymap.n('<M-S-~>', ':BufferLineCyclePrev<CR>', 'Previous buffer tab')
-- Buffer navigation with leader+arrow keys
keymap.n('<leader><Right>', '<cmd>bnext<CR>', 'Next buffer')
keymap.n('<leader><Left>', '<cmd>bprevious<CR>', 'Previous buffer')

-- Comment keymaps
keymap.n('<leader>/', '<cmd>lua require(\'Comment.api\').toggle.linewise.current()<cr>', 'Toggle comment')
keymap.v(
  '<leader>/',
  '<esc><cmd>lua require(\'Comment.api\').toggle.linewise(vim.fn.visualmode())<cr>',
  'Toggle comment'
)

-- LSP keymaps
keymap.n('K', '<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover documentation')
keymap.n('<leader>aa', '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Code action')
keymap.n('<leader>ar', '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol')

-- Indentation in visual mode
keymap.v('<', '<gv', 'Outdent line')
keymap.v('>', '>gv', 'Indent line')

-- Move lines up and down
keymap.v('J', ':m \'>+1<CR>gv=gv', 'Move selection down')
keymap.v('K', ':m \'<-2<CR>gv=gv', 'Move selection up')

-- Search and replace current word
keymap.n('<leader>sr', ':%s/<C-r><C-w>//g<Left><Left>', 'Search and replace word under cursor')
keymap.n('<leader>ss', function() require('telescope.builtin').lsp_document_symbols() end, 'Open Document Symbols')
keymap.n(
  '<leader>sS',
  function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
  'Open Workspace Symbols'
)

-- Open mini.files with '\'
keymap.n('\\', function()
  -- Open mini.files and reveal current file location
  local minifiles = require('mini.files')
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file ~= '' and vim.fn.filereadable(current_file) == 1 then
    minifiles.open(current_file)
    minifiles.reveal_cwd()
  else
    minifiles.open()
  end
end, 'Open MiniFiles file explorer')

-- Additional mini.files keybinding for current directory
keymap.n('<leader>fE', function() require('mini.files').open() end, 'Open MiniFiles in current directory')

-- ═══════════════════════════════════════════════════════════════════════════════
-- Function Keys - Optimized for Development Workflow
-- ═══════════════════════════════════════════════════════════════════════════════
-- F1-F4: Buffer/Window Navigation (complements tmux F1-F4 for window switching)
keymap.n('<F1>', '<cmd>bfirst<CR>', 'First buffer')
keymap.n('<F2>', '<cmd>bprevious<CR>', 'Previous buffer')
keymap.n('<F3>', '<cmd>bnext<CR>', 'Next buffer')
keymap.n('<F4>', '<cmd>blast<CR>', 'Last buffer')

-- F5-F8: File Operations & Quick Actions
keymap.n('<F5>', '<cmd>write<CR>', 'Save file')
keymap.n('<F6>', function()
  -- Open mini.files in current file directory
  local minifiles = require('mini.files')
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file ~= '' and vim.fn.filereadable(current_file) == 1 then
    minifiles.open(current_file)
    minifiles.reveal_cwd()
  else
    minifiles.open()
  end
end, 'Open file explorer')
keymap.n('<F7>', '<cmd>Telescope find_files<CR>', 'Find files')
keymap.n('<F8>', '<cmd>Telescope live_grep<CR>', 'Live grep')

-- F9-F12: Development Tools & Advanced Features
keymap.n('<F9>', '<cmd>Telescope buffers<CR>', 'Show buffers')
keymap.n('<F10>', '<cmd>Trouble diagnostics toggle<CR>', 'Toggle diagnostics')
keymap.n('<F11>', '<cmd>ToggleTerm<CR>', 'Toggle terminal')
keymap.n('<F12>', function()
  -- Smart help: show help for word under cursor or general help
  local word = vim.fn.expand('<cword>')
  if word ~= '' then
    vim.cmd('help ' .. word)
  else
    vim.cmd('help')
  end
end, 'Context help')

-- Shift+Function Keys for Advanced Operations
keymap.n('<S-F1>', '<cmd>tabnew<CR>', 'New tab')
keymap.n('<S-F2>', '<cmd>tabprevious<CR>', 'Previous tab')
keymap.n('<S-F3>', '<cmd>tabnext<CR>', 'Next tab')
keymap.n('<S-F4>', '<cmd>tabclose<CR>', 'Close tab')

keymap.n('<S-F5>', '<cmd>wall<CR>', 'Save all files')
keymap.n('<S-F6>', '<cmd>source %<CR>', 'Source current file')
keymap.n('<S-F7>', '<cmd>Telescope git_files<CR>', 'Git files')
keymap.n('<S-F8>', '<cmd>Telescope grep_string<CR>', 'Grep word under cursor')

keymap.n('<S-F9>', '<cmd>Telescope quickfix<CR>', 'Quickfix list')
keymap.n('<S-F10>', '<cmd>lua vim.diagnostic.open_float()<CR>', 'Show diagnostics')
keymap.n('<S-F11>', '<cmd>split | terminal<CR>', 'Split terminal')
keymap.n('<S-F12>', '<cmd>lua vim.lsp.buf.hover()<CR>', 'LSP hover')

-- ═══════════════════════════════════════════════════════════════════════════════
-- Tmux Integration & Session Management
-- ═══════════════════════════════════════════════════════════════════════════════

-- Session Management keybindings (using <leader>S prefix)
keymap.n('<leader>Ss', '<cmd>SessionSave<cr>', 'Save session')
keymap.n('<leader>Sr', '<cmd>SessionRestore<cr>', 'Restore session')
keymap.n('<leader>Sd', '<cmd>SessionDelete<cr>', 'Delete session')
keymap.n('<leader>Sf', '<cmd>Telescope session-lens search_session<cr>', 'Find session')
keymap.n('<leader>SP', '<cmd>SessionPurgeOrphaned<cr>', 'Purge orphaned sessions')
keymap.n('<leader>St', '<cmd>Telescope persisted<cr>', 'Telescope sessions')
keymap.n('<leader>Sl', '<cmd>SessionLoad<cr>', 'Load session')
keymap.n('<leader>SS', '<cmd>SessionSave<cr>', 'Save session (alt)')
keymap.n('<leader>Sx', '<cmd>SessionDelete<cr>', 'Delete session (alt)')

-- Tmux pane management (using <leader>T prefix)
keymap.n('<leader>Tn', '<cmd>TmuxNewWindow<cr>', 'New tmux window')
keymap.n('<leader>Th', '<cmd>TmuxSplitH<cr>', 'Split tmux pane horizontally')
keymap.n('<leader>Tv', '<cmd>TmuxSplitV<cr>', 'Split tmux pane vertically')
keymap.n('<leader>Tl', '<cmd>TmuxPanes<cr>', 'List nvim panes in tmux session')

-- Enhanced file reload keybindings for multi-instance scenarios
keymap.n('<leader>R', '<cmd>checktime<cr>', 'Check for external file changes')
keymap.n('<leader>rr', function()
  vim.cmd('checktime')
  vim.notify('Checked all buffers for external changes', vim.log.levels.INFO)
end, 'Reload all buffers from disk')

-- Quick session shortcuts for common workflows
keymap.n('<leader>qS', function()
  local cwd = vim.fn.getcwd()
  local session_name = vim.fn.fnamemodify(cwd, ':t')
  vim.cmd('SessionSave ' .. session_name)
end, 'Quick save project session')

keymap.n('<leader>qL', function()
  local cwd = vim.fn.getcwd()
  local session_name = vim.fn.fnamemodify(cwd, ':t')
  vim.cmd('SessionLoad ' .. session_name)
end, 'Quick load project session')

-- Focus and buffer synchronization
keymap.n('<leader>fs', function()
  -- Force focus sync and file check
  vim.cmd('redraw!')
  vim.cmd('checktime')
  if vim.env.TMUX then require('utils.tmux').refresh_client() end
end, 'Force focus sync and file check')

-- Multi-instance buffer management
keymap.n('<leader>ba', function()
  -- Check if buffer has been modified externally and reload if safe
  local buf = vim.api.nvim_get_current_buf()
  if not vim.bo[buf].modified then
    vim.cmd('checktime')
    vim.notify('Buffer synchronized with file system', vim.log.levels.INFO)
  else
    vim.notify('Buffer has unsaved changes - not reloading', vim.log.levels.WARN)
  end
end, 'Auto-sync current buffer')

-- Project-based workflow shortcuts
keymap.n('<leader>pw', function()
  -- Switch to project root and setup session
  local tmux = require('utils.tmux')
  if tmux.is_tmux() then tmux.setup_project_workflow() end
end, 'Setup project workflow')
