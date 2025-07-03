-- Keymaps configuration
local keymap = require('utils.keymap')
local notify = require('utils.notify')

-- ═══════════════════════════════════════════════════════════════════════════════
-- COMPREHENSIVE COMMAND-LINE WINDOW DISABLING
-- ═══════════════════════════════════════════════════════════════════════════════
-- Disable command-line window completely using multiple approaches
-- This prevents the annoying q: buffer that interferes with normal workflow

-- Method 1: Disable keybindings - ONLY in normal mode to avoid command-line delays
-- The 'c' mode mapping for 'q:' was causing delays when typing 'q' in command line
local cmd_keys = { 'q:', 'q/', 'q?' }

-- Only disable in normal, visual, and related modes - NOT in command-line mode
local safe_modes = { 'n', 'v', 'x', 'o', 'i', 't' }

for _, mode in ipairs(safe_modes) do
  for _, key in ipairs(cmd_keys) do
    vim.keymap.set(mode, key, '<Nop>', {
      remap = false,
      silent = true,
      desc = 'Disabled command-line window (' .. key .. ')',
    })
  end
end

-- Method 2: Disable cedit (command-line editing key)
vim.opt.cedit = '' -- Completely disable command-line window activation

-- Method 3: Create autocmd to prevent command-line window opening
vim.api.nvim_create_autocmd('CmdwinEnter', {
  group = vim.api.nvim_create_augroup('disable-cmdwin', {
    clear = true,
  }),
  desc = 'Prevent command-line window from opening',
  callback = function()
    -- Immediately close if somehow opened
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, false, true), 'n', false)
    notify.warn('Keymaps', 'Command-line window disabled')
    return true
  end,
})

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
keymap.n('<Esc>', '<cmd>nohlsearch<CR>', 'Clear search highlights')

-- Unified split commands (matching tmux)
keymap.n('<C-M-v>', '<cmd>vsplit<CR>', 'Split window vertically (unified)')
keymap.n('<C-M-s>', '<cmd>split<CR>', 'Split window horizontally (unified)')

-- Move windows around
keymap.n('<C-S-h>', '<C-w>H', 'Move window to the left')
keymap.n('<C-S-l>', '<C-w>L', 'Move window to the right')
keymap.n('<C-S-j>', '<C-w>J', 'Move window to the bottom')
keymap.n('<C-S-k>', '<C-w>K', 'Move window to the top')

-- File operations keymaps
keymap.n('<leader>fq', function() require('mini.bufremove').delete(0, false) end, 'Close file (preserve split)')
keymap.n('<leader>fQ', function()
  -- Close all buffers except current one
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()
  local closed_count = 0

  for _, buf in ipairs(buffers) do
    if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) then
      local success = pcall(require('mini.bufremove').delete, buf, false)
      if success then closed_count = closed_count + 1 end
    end
  end

  notify.info('Buffer Management', 'Closed ' .. closed_count .. ' buffers')
end, 'Close all buffers except current')
keymap.n('<leader>fw', '<cmd>write<CR>', 'Write file')

-- Buffer navigation with leader+arrow keys
keymap.n('<leader><Right>', '<cmd>bnext<CR>', 'Next buffer')
keymap.n('<leader><Left>', '<cmd>bprevious<CR>', 'Previous buffer')

-- LSP Goto keymaps
keymap.n('<leader>ga', vim.lsp.buf.code_action, 'Code Action')
keymap.n('<leader>gR', function() require('fzf-lua').lsp_references() end, 'List References')
keymap.n('<leader>gi', function() require('fzf-lua').lsp_implementations() end, 'List Implementations')
keymap.n('<leader>gd', function() require('fzf-lua').lsp_definitions() end, 'List Definitions')
keymap.n('<leader>gD', vim.lsp.buf.declaration, 'Goto Declaration')
keymap.n('<leader>gt', function() require('fzf-lua').lsp_typedefs() end, 'List Type Definitions')
keymap.n('<leader>gr', '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol')
keymap.n('<leader>gh', '<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover documentation')

-- Indentation in visual mode
keymap.v('<', '<gv', 'Outdent line')
keymap.v('>', '>gv', 'Indent line')

-- Move lines up and down
keymap.v('J', ':m \'>+1<CR>gv=gv', 'Move selection down')
keymap.v('K', ':m \'<-2<CR>gv=gv', 'Move selection up')

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

-- ═══════════════════════════════════════════════════════════════════════════════
-- Tmux Integration
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- Admin Category - <leader>A
-- ═══════════════════════════════════════════════════════════════════════════════
-- Tmux:       Aa=list_panes, Ar=reload_buffers, As=focus_sync
-- Session:    Ap=project_workflow, Ao=output_panel
-- ═══════════════════════════════════════════════════════════════════════════════

-- Tmux Integration
keymap.n('<leader>Aa', '<cmd>TmuxPanes<cr>', 'List nvim panes in tmux session')

keymap.n('<leader>Ar', function()
  vim.cmd('checktime')
  notify.info('Buffer Management', 'Checked all buffers for external changes')
end, 'Reload all buffers from disk')

-- Session and Project Management
keymap.n('<leader>Ap', function()
  -- Switch to project root and setup session
  local tmux = require('utils.tmux')
  if tmux.is_tmux() then tmux.setup_project_workflow() end
end, 'Setup project workflow')

keymap.n('<leader>Ao', '<cmd>OutputPanel<CR>', 'Toggle output panel')

-- Basic diagnostic keymaps
keymap.n('<leader>xq', vim.diagnostic.setloclist, 'Open diagnostic quickfix list')

-- Add all open buffers to quickfix list
vim.keymap.set('n', '<leader>sba', function()
  local buffers = vim.fn.getbufinfo({
    buflisted = 1,
  })
  local qf_list = {}
  for _, buf in ipairs(buffers) do
    if buf.name and buf.name ~= '' then
      table.insert(qf_list, {
        filename = buf.name,
        lnum = buf.lnum or 1,
      })
    end
  end
  vim.fn.setqflist(qf_list)
  require('trouble').open('quickfix')
end, {
  desc = 'Add all buffers to quickfix',
})

-- Quick diagnostic navigation (IntelliJ-style)
keymap.n('[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
keymap.n(']d', vim.diagnostic.goto_next, 'Next diagnostic')
keymap.n(
  '[e',
  function()
    vim.diagnostic.goto_prev({
      severity = vim.diagnostic.severity.ERROR,
    })
  end,
  'Previous error'
)
keymap.n(
  ']e',
  function()
    vim.diagnostic.goto_next({
      severity = vim.diagnostic.severity.ERROR,
    })
  end,
  'Next error'
)

-- ═══════════════════════════════════════════════════════════════════════════════
-- Tab Management
-- ═══════════════════════════════════════════════════════════════════════════════

-- Basic tab operations with <leader>t prefix
keymap.n('<leader>tn', '<cmd>tabnew<cr>', 'New tab')
keymap.n('<leader>to', '<cmd>tabnew %<cr>', 'Open file in new tab')
keymap.n('<leader>tc', '<cmd>tabclose<cr>', 'Close tab')
keymap.n('<leader>t]', '<cmd>tabnext<cr>', 'Next tab')
keymap.n('<leader>t[', '<cmd>tabprevious<cr>', 'Previous tab')
keymap.n('<leader>tf', '<cmd>tabfirst<cr>', 'First tab')
keymap.n('<leader>tl', '<cmd>tablast<cr>', 'Last tab')

-- Enhanced tab move with prompt for position
keymap.n('<leader>tm', function()
  local pos = vim.fn.input('Move tab to position (0 for first, $ for last): ')
  if pos ~= '' then
    if pos == '$' then
      vim.cmd('tabmove $')
    else
      vim.cmd('tabmove ' .. pos)
    end
  end
end, 'Move tab to position')

-- Arrow key navigation for tabs
keymap.n('<leader><Up>', '<cmd>tabnext<cr>', 'Next tab')
keymap.n('<leader><Down>', '<cmd>tabprevious<cr>', 'Previous tab')

-- Modern Web Development Keymaps

-- Web Development Utility Functions
keymap.n('<leader>wf', function()
  -- Format current buffer with web-specific formatter
  local ft = vim.bo.filetype
  if vim.tbl_contains({ 'html', 'css', 'javascript', 'typescript' }, ft) then
    require('conform').format({
      async = true,
    })
  else
    notify.warn('Web Development', 'Not a web file type')
  end
end, 'Format web file')

-- Toggle embedded language highlighting
keymap.n('<leader>we', function()
  if vim.bo.filetype == 'html' then
    -- Toggle highlighting for embedded JS/CSS
    vim.cmd('syntax sync fromstart')
    notify.info('Web Development', 'Refreshed embedded language highlighting')
  end
end, 'Refresh embedded language highlighting')

-- Quick tag wrapping
keymap.v('<leader>wt', function()
  local tag = vim.fn.input('Tag name: ')
  if tag ~= '' then vim.cmd(string.format('\'<,\'>s/\\%V\\(.*\\)\\%V/<' .. tag .. '>\\1<\\/' .. tag .. '>/')) end
end, 'Wrap selection with HTML tag')

-- Live server toggle (if live-server is installed)
keymap.n('<leader>wl', function()
  local cwd = vim.fn.getcwd()
  vim.fn.jobstart({ 'live-server', cwd }, {
    detach = true,
    on_exit = function() notify.info('Live Server', 'Server stopped') end,
  })
  notify.info('Live Server', 'Started for: ' .. cwd)
end, 'Start live server')

-- Open in browser
keymap.n('<leader>wo', function()
  local filepath = vim.fn.expand('%:p')
  if vim.bo.filetype == 'html' then
    if vim.fn.has('mac') == 1 then
      vim.fn.jobstart({ 'open', filepath }, {
        detach = true,
      })
    elseif vim.fn.has('unix') == 1 then
      vim.fn.jobstart({ 'xdg-open', filepath }, {
        detach = true,
      })
    end
    notify.info('Web Development', 'Opened in browser: ' .. vim.fn.expand('%:t'))
  else
    notify.warn('Web Development', 'Not an HTML file')
  end
end, 'Open HTML file in browser')

-- Tailwind utilities
keymap.n('<leader>wT', function()
  -- Sort Tailwind classes in current line
  local line = vim.api.nvim_get_current_line()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Simple Tailwind class sorting (basic implementation)
  local sorted_line = line:gsub('class="([^"]*)"', function(classes)
    local class_list = vim.split(classes, '%s+')
    table.sort(class_list)
    return 'class="' .. table.concat(class_list, ' ') .. '"'
  end)

  vim.api.nvim_set_current_line(sorted_line)
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end, 'Sort Tailwind classes')

-- Quick console.log for debugging
keymap.n('<leader>wL', function()
  local word = vim.fn.expand('<cword>')
  local log_line = string.format('console.log(\'%s:\', %s);', word, word)
  vim.api.nvim_put({ log_line }, 'l', true, true)
end, 'Insert console.log for word under cursor')

-- ═══════════════════════════════════════════════════════════════════════════════
-- Navigation Category - g + Arrow Keys
-- ═══════════════════════════════════════════════════════════════════════════════
-- Definition:     g<Down>=goto_definition
-- Jumplist:       g<Left>=jumplist_prev, g<Right>=jumplist_next
-- ═══════════════════════════════════════════════════════════════════════════════

-- Go to definition
keymap.n('g<Down>', function() vim.lsp.buf.definition() end, 'Go to definition')

-- Navigate jumplist (cursor/buffer position history)
keymap.n('g<Left>', '<C-o>', 'Previous cursor position (jumplist)')
keymap.n('g<Right>', '<C-i>', 'Next cursor position (jumplist)')
