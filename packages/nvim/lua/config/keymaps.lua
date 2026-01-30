local keymap = require('utils.keymap')
local notify = require('utils.notify')

-- Disable the command-line window (q:, q/, q?)
local cmd_keys = { 'q:', 'q/', 'q?' }

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

vim.opt.cedit = ''

vim.api.nvim_create_autocmd('CmdwinEnter', {
  group = vim.api.nvim_create_augroup('disable-cmdwin', {
    clear = true,
  }),
  desc = 'Prevent command-line window from opening',
  callback = function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, false, true), 'n', false)
    notify.warn('Keymaps', 'Command-line window disabled')
    return true
  end,
})

keymap.n('<Esc>', '<cmd>nohlsearch<CR>', 'Clear search highlights')

keymap.n('<C-M-v>', '<cmd>vsplit<CR>', 'Split window vertically (unified)')
keymap.n('<C-M-s>', '<cmd>split<CR>', 'Split window horizontally (unified)')

-- Move windows around
keymap.n('<C-S-h>', '<C-w>H', 'Move window to the left')
keymap.n('<C-S-l>', '<C-w>L', 'Move window to the right')
keymap.n('<C-S-j>', '<C-w>J', 'Move window to the bottom')
keymap.n('<C-S-k>', '<C-w>K', 'Move window to the top')

-- Save
keymap.n('<C-s>', '<cmd>write<CR>', 'Save buffer')
keymap.i('<C-s>', '<C-o><cmd>write<CR>', 'Save buffer')

-- ═══════════════════════════════════════════════════════════════════════════════
-- Buffers - <leader>b
-- ═══════════════════════════════════════════════════════════════════════════════
keymap.n('<leader><Left>', '<cmd>bprevious<CR>', 'Previous buffer')
keymap.n('<leader><Right>', '<cmd>bnext<CR>', 'Next buffer')
keymap.n('<leader>bd', function() require('mini.bufremove').delete(0, false) end, 'Close')
keymap.n('<leader>ba', function()
  local cur = vim.api.nvim_get_current_buf()
  local n = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= cur and vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == '' then
      local ok = pcall(require('mini.bufremove').delete, b, false)
      if ok then n = n + 1 end
    end
  end
  if n > 0 then notify.info('Buffers', 'Closed ' .. n) end
end, 'Close all file buffers except current')
keymap.n('<leader>bD', '<cmd>CloseDeletedBuffers<CR>', 'Close deleted')
keymap.n('<leader>br', '<cmd>e!<CR>', 'Reload current')
keymap.n('<leader>bR', function()
  vim.cmd('checktime')
  notify.info('Buffers', 'Reloaded from disk')
end, 'Reload all')
keymap.n('<leader>bA', function()
  local n = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == '' then
      local ok = pcall(require('mini.bufremove').delete, b, false)
      if ok then n = n + 1 end
    end
  end
  if n > 0 then notify.info('Buffers', 'Closed ' .. n) end
end, 'Close all file buffers')
keymap.n('<leader>bq', function()
  local qf = {}
  for _, b in
    ipairs(vim.fn.getbufinfo({
      buflisted = 1,
    }))
  do
    if b.name and b.name ~= '' then table.insert(qf, {
      filename = b.name,
      lnum = b.lnum or 1,
    }) end
  end
  vim.fn.setqflist(qf)
  _G.buffer_list_panel = true
  require('trouble').open({
    mode = 'qflist',
    win = {
      position = 'right',
      size = {
        width = 40,
      },
    },
  })
end, 'Buffer list')
keymap.n('<leader>bqa', function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name == '' then
    notify.warn('Buffer list', 'Cannot add unnamed buffer')
    return
  end
  local abs_path = vim.fn.fnamemodify(buf_name, ':p')
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local qf = vim.fn.getqflist()
  for _, item in ipairs(qf) do
    if vim.fn.fnamemodify(item.filename or '', ':p') == abs_path then
      notify.info('Buffer list', 'Buffer already in list')
      return
    end
  end
  vim.fn.setqflist({ { filename = abs_path, lnum = lnum } }, 'a')
  if require('trouble').is_open('qflist') then require('trouble').refresh('qflist') end
  notify.info('Buffer list', 'Added buffer')
end, 'Add current buffer to list')
keymap.n('<leader>bqr', function()
  local item_to_remove = nil
  local trouble = require('trouble')
  local view_module = require('trouble.view')
  local current_win = vim.api.nvim_get_current_win()

  -- When in Trouble qflist panel: remove the selected item under cursor
  if trouble.is_open('qflist') then
    local views = view_module.get({ mode = 'qflist', open = true })
    for _, entry in ipairs(views) do
      if entry.view and entry.view.win and entry.view.win.win == current_win then
        local loc = entry.view:at()
        if loc and loc.item and loc.item.filename then
          item_to_remove = vim.fn.fnamemodify(loc.item.filename, ':p')
          break
        end
      end
    end
  end

  -- When in a normal buffer: remove current buffer from list
  if not item_to_remove then
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name == '' then
      notify.warn('Buffer list', 'Cannot remove unnamed buffer')
      return
    end
    item_to_remove = vim.fn.fnamemodify(buf_name, ':p')
  end

  -- getqflist() returns items with bufnr, not filename - resolve bufnr to path
  local function item_path(item)
    if item.filename and item.filename ~= '' then return vim.fn.fnamemodify(item.filename, ':p') end
    if item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) then
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item.bufnr), ':p')
    end
    return ''
  end

  local qf = vim.fn.getqflist()
  local filtered = {}
  for _, item in ipairs(qf) do
    local path = item_path(item)
    if path ~= '' and path ~= item_to_remove then
      table.insert(filtered, {
        filename = path,
        lnum = item.lnum or 1,
      })
    end
  end
  vim.fn.setqflist(filtered, ' ')
  if trouble.is_open('qflist') then trouble.refresh('qflist') end
  notify.info('Buffer list', 'Removed from list')
end, 'Remove selected buffer from list')

-- F2: Toggle current buffer in/out of quickfix list, open panel if closed
local function toggle_buffer_in_qflist()
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name == '' then
    notify.warn('Buffer list', 'Cannot toggle unnamed buffer')
    return
  end
  local abs_path = vim.fn.fnamemodify(buf_name, ':p')
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local trouble = require('trouble')

  local function item_path(item)
    if item.filename and item.filename ~= '' then return vim.fn.fnamemodify(item.filename, ':p') end
    if item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) then
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item.bufnr), ':p')
    end
    return ''
  end

  local qf = vim.fn.getqflist()
  local in_list = false
  for _, item in ipairs(qf) do
    if item_path(item) == abs_path then
      in_list = true
      break
    end
  end

  if in_list then
    local filtered = {}
    for _, item in ipairs(qf) do
      local path = item_path(item)
      if path ~= '' and path ~= abs_path then table.insert(filtered, { filename = path, lnum = item.lnum or 1 }) end
    end
    vim.fn.setqflist(filtered, ' ')
    notify.info('Buffer list', 'Removed from list')
  else
    vim.fn.setqflist({ { filename = abs_path, lnum = lnum } }, 'a')
    notify.info('Buffer list', 'Added to list')
  end

  if trouble.is_open('qflist') then
    trouble.refresh('qflist')
  else
    trouble.open({
      mode = 'qflist',
      win = { position = 'right', size = { width = 40 } },
    })
  end
end
keymap.n('<F2>', toggle_buffer_in_qflist, 'Toggle buffer in quickfix list')
keymap.i('<F2>', toggle_buffer_in_qflist, 'Toggle buffer in quickfix list')

-- LSP Goto keymaps
keymap.n('<leader>ga', vim.lsp.buf.code_action, 'Code Action')
keymap.n('<leader>gR', function() require('fzf-lua').lsp_references() end, 'List References')
keymap.n('<leader>gi', function() require('fzf-lua').lsp_implementations() end, 'List Implementations')
keymap.n('<leader>gd', function() require('fzf-lua').lsp_definitions() end, 'List Definitions')
keymap.n('<leader>gD', vim.lsp.buf.declaration, 'Goto Declaration')
keymap.n('<leader>gt', function() require('fzf-lua').lsp_typedefs() end, 'List Type Definitions')
keymap.n('<leader>gr', '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol')
keymap.n('<leader>gh', '<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover documentation')

-- Delete from cursor to end of line (Ctrl+K; normal and insert)
keymap.n('<C-k>', 'd$', 'Delete to end of line')
keymap.i('<C-k>', '<C-o>d$', 'Delete to end of line')

-- Indentation in visual mode
keymap.v('<', '<gv', 'Outdent line')
keymap.v('>', '>gv', 'Indent line')

-- Move lines up and down
keymap.v('J', ':m \'>+1<CR>gv=gv', 'Move selection down')
keymap.v('K', ':m \'<-2<CR>gv=gv', 'Move selection up')

-- ═══════════════════════════════════════════════════════════════════════════════
-- Tmux Integration
-- ═══════════════════════════════════════════════════════════════════════════════

-- ea=list_panes, ep=project_workflow
keymap.n('<leader>ea', '<cmd>TmuxPanes<cr>', 'List nvim panes in tmux session')

-- Session and Project Management
keymap.n('<leader>ep', function()
  -- Switch to project root and setup session
  local tmux = require('utils.tmux')
  if tmux.is_tmux() then tmux.setup_project_workflow() end
end, 'Setup project workflow')

-- Basic diagnostic keymaps
keymap.n('<leader>xq', vim.diagnostic.setloclist, 'Open diagnostic quickfix list')

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

-- Command-line abbreviations
vim.cmd([[cnoreabbrev git Git]])
vim.cmd([[cnoreabbrev g G]])

-- ═══════════════════════════════════════════════════════════════════════════════
-- Odin-specific keybindings
-- ═══════════════════════════════════════════════════════════════════════════════
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'odin',
  callback = function(args)
    local buf = args.buf
    local opts = {
      buffer = buf,
      silent = true,
    }

    -- Build and run commands for Odin
    vim.keymap.set(
      'n',
      '<leader>zy',
      function()
        local cmd = 'odin build . -out:' .. vim.fn.expand('%:t:r')
        vim.cmd('terminal ' .. cmd)
      end,
      vim.tbl_extend('force', opts, {
        desc = 'Build Odin project',
      })
    )

    vim.keymap.set(
      'n',
      '<leader>zr',
      function()
        local binary_name = vim.fn.expand('%:t:r')
        local cmd = 'odin run . -out:' .. binary_name
        vim.cmd('terminal ' .. cmd)
      end,
      vim.tbl_extend('force', opts, {
        desc = 'Run Odin project',
      })
    )

    vim.keymap.set(
      'n',
      '<leader>zc',
      function()
        local cmd = 'odin check .'
        vim.cmd('terminal ' .. cmd)
      end,
      vim.tbl_extend('force', opts, {
        desc = 'Check Odin project',
      })
    )

    vim.keymap.set(
      'n',
      '<leader>zt',
      function()
        local cmd = 'odin test .'
        vim.cmd('terminal ' .. cmd)
      end,
      vim.tbl_extend('force', opts, {
        desc = 'Test Odin project',
      })
    )

    -- Format with odinfmt
    vim.keymap.set(
      'n',
      '<leader>zf',
      function()
        vim.lsp.buf.format({
          async = true,
        })
      end,
      vim.tbl_extend('force', opts, {
        desc = 'Format Odin file',
      })
    )

    -- Quick Odin documentation lookup
    vim.keymap.set(
      'n',
      '<leader>zd',
      function()
        local word = vim.fn.expand('<cword>')
        vim.cmd('terminal odin doc ' .. word)
      end,
      vim.tbl_extend('force', opts, {
        desc = 'Odin documentation lookup',
      })
    )
  end,
  desc = 'Odin-specific keybindings',
})
