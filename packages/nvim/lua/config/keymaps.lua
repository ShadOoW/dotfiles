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
keymap.n('<leader>bc', function() require('mini.bufremove').delete(0, false) end, 'Close')
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
keymap.n('<leader>bC', '<cmd>CloseDeletedBuffers<CR>', 'Close deleted')
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
keymap.n('<leader>xb', function()
  local qf = {}
  for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if b.name and b.name ~= '' then
      table.insert(qf, { filename = b.name, lnum = b.lnum or 1 })
    end
  end
  vim.fn.setqflist(qf)
  require('trouble').open({ mode = 'qflist', win = { position = 'right', size = { width = 40 } } })
end, 'Buffer list (trouble)')

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
      if path ~= '' and path ~= abs_path then
        table.insert(filtered, {
          filename = path,
          lnum = item.lnum or 1,
        })
      end
    end
    vim.fn.setqflist(filtered, ' ')
    notify.info('Buffer list', 'Removed from list')
  else
    vim.fn.setqflist({ {
      filename = abs_path,
      lnum = lnum,
    } }, 'a')
    notify.info('Buffer list', 'Added to list')
  end

  if trouble.is_open('qflist') then
    trouble.refresh('qflist')
  else
    trouble.open({
      mode = 'qflist',
      win = {
        position = 'right',
        size = {
          width = 40,
        },
      },
    })
  end
end
keymap.n('<F2>', toggle_buffer_in_qflist, 'Toggle buffer in quickfix list')
keymap.i('<F2>', toggle_buffer_in_qflist, 'Toggle buffer in quickfix list')

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

-- TypeScript project-wide check
local function tsc_check()
  local project_root = vim.fn.getcwd()
  local tsconfig = project_root .. '/tsconfig.json'

  if vim.fn.filereadable(tsconfig) == 0 then
    notify.warn('TypeScript', 'No tsconfig.json found')
    return
  end

  notify.info('TypeScript', 'Running tsc --noEmit...')

  local Job = require('plenary.job')
  Job:new({
    command = 'npx',
    args = { 'tsc', '--noEmit', '--pretty', 'false' },
    cwd = project_root,
    on_exit = function(job, _)
      local output = job:result()
      local stderr = job:stderr_result()

      if stderr and #stderr > 0 then vim.list_extend(output, stderr) end

      local items = {}
      for _, line in ipairs(output) do
        local file, lnum, col, severity, code, message = line:match('(.+)%((%d+),(%d+)%): (%w+) (TS%d+): (.+)')
        if file and lnum and col and message then
          local filepath = vim.fn.fnamemodify(project_root .. '/' .. file, ':p')
          table.insert(items, {
            filename = filepath,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = string.format('[%s] %s', code, message),
            type = severity == 'error' and 'E' or 'W',
          })
        end
      end

      vim.schedule(function()
        vim.fn.setqflist(items, 'r')
        require('plugins.ui.panel-manager').open('trouble')

        if #items > 0 then
          notify.info('TypeScript', string.format('Found %d issues', #items))
        else
          notify.success('TypeScript', 'No errors found')
        end
      end)
    end,
  }):start()
end

keymap.n('<leader>xW', tsc_check, 'TypeScript: run project check (tsc --noEmit)')

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

-- ═══════════════════════════════════════════════════════════════════════════════
-- Navigation Category - g + Arrow Keys
-- ═══════════════════════════════════════════════════════════════════════════════
-- Definition:     gd=goto_definition
-- Type Def:      gt=goto_type_definition
-- Jumplist:      gh=jumplist_prev, gl=jumplist_next
-- ═══════════════════════════════════════════════════════════════════════════════

-- Jumplist navigation
keymap.n('gh', '<C-o>', 'Previous cursor position (jumplist)')
keymap.n('gl', '<C-i>', 'Next cursor position (jumplist)')

-- LSP Navigation with g + special keys
keymap.n('gd', function() vim.lsp.buf.definition() end, 'Go to definition')
keymap.n('gi', function() vim.lsp.buf.implementation() end, 'Go to implementation')
keymap.n('gt', function() vim.lsp.buf.type_definition() end, 'Go to type definition')

-- Code actions and rename
keymap.n('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
keymap.n('<leader>cr', '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol')

-- FZF-Lua LSP pickers
keymap.n('<leader>sa', function() require('fzf-lua').lsp_references() end, 'LSP References')
keymap.n('<leader>si', function() require('fzf-lua').lsp_implementations() end, 'LSP Implementations')

-- Delete from cursor to end of line

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
