-- Keymaps configuration
local keymap = require('utils.keymap')

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

  vim.notify('Closed ' .. closed_count .. ' buffers', vim.log.levels.INFO, {
    title = 'Buffer Management',
  })
end, 'Close all buffers except current')
keymap.n('<leader>fw', '<cmd>write<CR>', 'Write file')

-- Buffer navigation with leader+arrow keys
keymap.n('<leader><Right>', '<cmd>bnext<CR>', 'Next buffer')
keymap.n('<leader><Left>', '<cmd>bprevious<CR>', 'Previous buffer')

-- LSP Goto keymaps
keymap.n('<leader>ga', vim.lsp.buf.code_action, 'Code Action')
keymap.n('<leader>gr', function() require('telescope.builtin').lsp_references() end, 'List References')
keymap.n('<leader>gi', function() require('telescope.builtin').lsp_implementations() end, 'List Implementations')
keymap.n('<leader>gd', function() require('telescope.builtin').lsp_definitions() end, 'List Definitions')
keymap.n('<leader>gD', vim.lsp.buf.declaration, 'Goto Declaration')
keymap.n('<leader>gt', function() require('telescope.builtin').lsp_type_definitions() end, 'List Type Definitions')
keymap.n('<leader>gr', '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol')
keymap.n('<leader>gh', '<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover documentation')

-- Indentation in visual mode
keymap.v('<', '<gv', 'Outdent line')
keymap.v('>', '>gv', 'Indent line')

-- Move lines up and down
keymap.v('J', ':m \'>+1<CR>gv=gv', 'Move selection down')
keymap.v('K', ':m \'<-2<CR>gv=gv', 'Move selection up')

-- Search and replace current word
keymap.n('<leader>sr', ':%s/<C-r><C-w>//g<Left><Left>', 'Word under cursor')
keymap.n('<leader>sm', '<cmd>NoiceTelescope<cr>', 'Noice messages')

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
-- F7 removed - use <leader>sf for find files
keymap.n('<F8>', '<cmd>Telescope live_grep<CR>', 'Live grep')

-- F9-F12: Development Tools & Advanced Features
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
keymap.n('<S-F7>', '<cmd>Telescope git_files<CR>', 'Git files (also <leader>hf)')
keymap.n('<S-F8>', '<cmd>Telescope grep_string<CR>', 'Grep word under cursor')

keymap.n('<S-F9>', '<cmd>Telescope quickfix<CR>', 'Quickfix list')
keymap.n('<S-F10>', '<cmd>lua vim.diagnostic.open_float()<CR>', 'Show diagnostics')
keymap.n('<S-F11>', '<cmd>split | terminal<CR>', 'Split terminal')
keymap.n('<S-F12>', '<cmd>lua vim.lsp.buf.hover()<CR>', 'LSP hover')

-- ═══════════════════════════════════════════════════════════════════════════════
-- Tmux Integration
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- Admin Category - <leader>A
-- ═══════════════════════════════════════════════════════════════════════════════
-- Tmux:       Aa=list_panes, Ar=reload_buffers, As=focus_sync
-- Noice:      An=noice_search, Al=last_message, Ah=history, AD=dismiss_all
-- Session:    Ap=project_workflow, Ao=output_panel
-- ═══════════════════════════════════════════════════════════════════════════════

-- Tmux Integration
keymap.n('<leader>Aa', '<cmd>TmuxPanes<cr>', 'List nvim panes in tmux session')

keymap.n('<leader>Ar', function()
  vim.cmd('checktime')
  vim.notify('Checked all buffers for external changes', vim.log.levels.INFO)
end, 'Reload all buffers from disk')

-- Noice Integration

keymap.n('<leader>Al', function() require('noice').cmd('last') end, 'Noice Last message')

keymap.n('<leader>Ah', function() require('noice').cmd('history') end, 'Noice History')

keymap.n('<leader>AD', function() require('noice').cmd('dismiss') end, 'Noice Dismiss all')

-- Session and Project Management
keymap.n('<leader>Ap', function()
  -- Switch to project root and setup session
  local tmux = require('utils.tmux')
  if tmux.is_tmux() then tmux.setup_project_workflow() end
end, 'Setup project workflow')

keymap.n('<leader>Ao', '<cmd>OutputPanel<CR>', 'Toggle output panel')

-- Diagnostic keymaps
keymap.n('<leader>pq', vim.diagnostic.setloclist, 'Open diagnostic quickfix list')

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

-- ═══════════════════════════════════════════════════════════════════════════════
-- Plugin Specific Keymaps (Consolidated from other files)
-- ═══════════════════════════════════════════════════════════════════════════════

-- File operations (from genghis.lua)
keymap.n('<leader>Fp', '<cmd>Genghis copyFilepath<CR>', 'Copy file path')
keymap.n('<leader>Fy', '<cmd>Genghis copyFilename<CR>', 'Copy filename')
keymap.n('<leader>Fd', '<cmd>Genghis duplicateFile<CR>', 'Duplicate file')
keymap.n('<leader>Fr', '<cmd>Genghis renameFile<CR>', 'Rename file')
keymap.n('<leader>Fx', '<cmd>Genghis chmodx<CR>', 'Make file executable')
keymap.v('<leader>Ff', ':\'<,\'>Genghis newFileFromSelection<CR>', 'New file from selection')
keymap.n('<leader>Fm', '<cmd>Genghis moveFile<CR>', 'Move file')
keymap.n('<leader>Ft', '<cmd>Genghis trashFile<CR>', 'Trash file')
keymap.v('<leader>FR', ':\'<,\'>Genghis renameFileToSelection<CR>', 'Rename file to selection')

-- Trouble diagnostics (using modern Trouble v3 commands)
keymap.n('<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', 'Toggle trouble diagnostics')
keymap.n('<leader>xw', '<cmd>Trouble diagnostics toggle<cr>', 'Workspace diagnostics')
keymap.n('<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', 'Document diagnostics')
keymap.n('<leader>xl', '<cmd>Trouble loclist toggle<cr>', 'Location list')
keymap.n('<leader>xq', '<cmd>Trouble qflist toggle<cr>', 'Quickfix list')
keymap.n('<leader>xr', '<cmd>Trouble lsp toggle<cr>', 'LSP references')

-- ═══════════════════════════════════════════════════════════════════════════════
-- Git Category - <leader>h (Hunks & Git operations)
-- ═══════════════════════════════════════════════════════════════════════════════
-- Hunks:      hj=next_hunk, hk=prev_hunk, hp=preview_hunk
-- Staging:    hs=stage_hunk, hS=stage_buffer, hr=reset_hunk, hR=reset_buffer, hu=undo_stage
-- View:       hb=blame_line, hd=diff_this, hD=diff_this~, htb=toggle_blame, htd=toggle_deleted
-- Files:      hf=git_files, hc=git_commits, hB=git_branches, hst=git_status
-- ═══════════════════════════════════════════════════════════════════════════════

-- Hunk Navigation
keymap.n(
  '<leader>hj',
  function()
    if vim.wo.diff then return ']c' end
    vim.schedule(function() require('gitsigns').next_hunk() end)
    return '<Ignore>'
  end,
  '[H]unk Next ([j] down)',
  {
    expr = true,
  }
)

keymap.n(
  '<leader>hk',
  function()
    if vim.wo.diff then return '[c' end
    vim.schedule(function() require('gitsigns').prev_hunk() end)
    return '<Ignore>'
  end,
  '[H]unk Previous ([k] up)',
  {
    expr = true,
  }
)

keymap.n('<leader>hp', function() require('gitsigns').preview_hunk() end, '[H]unk [P]review')

-- Hunk Staging Operations
keymap.n('<leader>hs', '<cmd>Gitsigns stage_hunk<CR>', '[H]unk [S]tage')
keymap.v('<leader>hs', ':Gitsigns stage_hunk<CR>', '[H]unk [S]tage')

keymap.n('<leader>hS', function() require('gitsigns').stage_buffer() end, '[H]unk [S]tage entire buffer')

keymap.n('<leader>hr', '<cmd>Gitsigns reset_hunk<CR>', '[H]unk [R]eset')
keymap.v('<leader>hr', ':Gitsigns reset_hunk<CR>', '[H]unk [R]eset')

keymap.n('<leader>hR', function() require('gitsigns').reset_buffer() end, '[H]unk [R]eset entire buffer')

keymap.n('<leader>hu', function() require('gitsigns').undo_stage_hunk() end, '[H]unk [U]ndo stage')

-- Git View and Blame
keymap.n('<leader>hb', function()
  require('gitsigns').blame_line({
    full = true,
  })
end, '[H]unk [B]lame line')

keymap.n('<leader>htb', function() require('gitsigns').toggle_current_line_blame() end, '[H]unk [T]oggle [B]lame')

keymap.n('<leader>hd', function() require('gitsigns').diffthis() end, '[H]unk [D]iff this')

keymap.n('<leader>hD', function() require('gitsigns').diffthis('~') end, '[H]unk [D]iff this (against index)')

keymap.n('<leader>htd', function() require('gitsigns').toggle_deleted() end, '[H]unk [T]oggle [D]eleted')

-- Git File Operations (from Telescope)
keymap.n(
  '<leader>hf',
  function()
    require('telescope.builtin').git_files(require('telescope.themes').get_dropdown({
      previewer = false,
    }))
  end,
  '[H]unk Git [F]iles'
)

keymap.n(
  '<leader>hc',
  function() require('telescope.builtin').git_commits(require('telescope.themes').get_ivy()) end,
  '[H]unk Git [C]ommits'
)

keymap.n(
  '<leader>hB',
  function()
    require('telescope.builtin').git_branches(require('telescope.themes').get_dropdown({
      previewer = false,
    }))
  end,
  '[H]unk Git [B]ranches'
)

keymap.n(
  '<leader>hst',
  function() require('telescope.builtin').git_status(require('telescope.themes').get_ivy()) end,
  '[H]unk Git [St]atus'
)

-- Buffer management (from hbac.lua)
keymap.n('<leader>fW', function() require('hbac').close_unpinned() end, 'Close all unpinned buffers')
keymap.n('<leader>fP', function() require('hbac').toggle_pin() end, 'Toggle pin buffer')

-- Smart window management (from smart-splits.lua)
keymap.n('<C-Left>', function() require('smart-splits').resize_left() end, 'Resize window left')
keymap.n('<C-Right>', function() require('smart-splits').resize_right() end, 'Resize window right')
keymap.n('<C-Up>', function() require('smart-splits').resize_up() end, 'Resize window up')
keymap.n('<C-Down>', function() require('smart-splits').resize_down() end, 'Resize window down')
keymap.n('<leader>wv', '<cmd>vsplit<CR>', 'Split window vertically')
keymap.n('<leader>ws', '<cmd>split<CR>', 'Split window horizontally')
keymap.n('<leader>wq', '<cmd>close<CR>', 'Close window')

-- Buffer swapping
keymap.n('<leader>w<Left>', function()
  local function safe_swap_buf_left()
    if vim.fn.winnr('h') ~= vim.fn.winnr() then require('smart-splits').swap_buf_left() end
  end
  safe_swap_buf_left()
end, 'Swap buffer left')
keymap.n('<leader>w<Down>', function() require('smart-splits').swap_buf_down() end, 'Swap buffer down')
keymap.n('<leader>w<Up>', function() require('smart-splits').swap_buf_up() end, 'Swap buffer up')
keymap.n('<leader>w<Right>', function()
  local function safe_swap_buf_right()
    if vim.fn.winnr('l') ~= vim.fn.winnr() then require('smart-splits').swap_buf_right() end
  end
  safe_swap_buf_right()
end, 'Swap buffer right')

keymap.n('gk', '<cmd>AerialPrev<CR>', 'Previous Symbol')
keymap.n('gj', '<cmd>AerialNext<CR>', 'Next Symbol')

-- Modern Web Development Keymaps

-- Web Development Utility Functions
keymap.n('<leader>wf', function()
  -- Format current buffer with web-specific formatter
  local ft = vim.bo.filetype
  if vim.tbl_contains({ 'html', 'css', 'javascript', 'typescript' }, ft) then
    vim.cmd('lua require("conform").format({ async = true })')
  else
    vim.notify('Not a web file type', vim.log.levels.WARN)
  end
end, 'Format web file')

-- Toggle embedded language highlighting
keymap.n('<leader>we', function()
  if vim.bo.filetype == 'html' then
    -- Toggle highlighting for embedded JS/CSS
    vim.cmd('syntax sync fromstart')
    vim.notify('Refreshed embedded language highlighting', vim.log.levels.INFO)
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
    on_exit = function() vim.notify('Live server stopped', vim.log.levels.INFO) end,
  })
  vim.notify('Live server started for: ' .. cwd, vim.log.levels.INFO)
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
    vim.notify('Opened in browser: ' .. vim.fn.expand('%:t'), vim.log.levels.INFO)
  else
    vim.notify('Not an HTML file', vim.log.levels.WARN)
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

-- Additional development keymaps...

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
