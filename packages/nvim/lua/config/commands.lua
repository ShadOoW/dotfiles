-- All user commands for Neovim configuration
-- Centralized command definitions
local notify = require('utils.notify')
vim.api.nvim_create_user_command('Qa', function() vim.cmd('qall') end, {
  desc = 'Quit all',
})

-- Buffer delete command that preserves splits
vim.api.nvim_create_user_command('Bd', function(opts) require('mini.bufremove').delete(0, opts.bang) end, {
  bang = true,
  desc = 'Delete buffer without closing split (using mini.bufremove)',
})

-- Quit command that preserves splits
vim.api.nvim_create_user_command('Q', function(opts)
  local buf = vim.api.nvim_get_current_buf()

  -- Check if buffer has unsaved changes and no bang
  if vim.bo[buf].modified and not opts.bang then
    notify.error('Commands', 'No write since last change (add ! to override)')
    return
  end

  -- If there are multiple windows, delete buffer instead of closing window
  if #vim.api.nvim_list_wins() > 1 then
    require('mini.bufremove').delete(0, opts.bang)
  else
    -- If only one window, use normal quit behavior
    if opts.bang then
      vim.cmd('quit!')
    else
      vim.cmd('quit')
    end
  end
end, {
  bang = true,
  desc = 'Quit without closing split (using mini.bufremove)',
})

-- ===== Tmux Integration Commands =====

vim.api.nvim_create_user_command('TmuxNewWindow', function(opts)
  local tmux = require('utils.tmux')
  tmux.new_window(opts.args)
end, {
  nargs = '?',
  desc = 'Create new tmux window',
})

vim.api.nvim_create_user_command('TmuxSplitH', function(opts)
  local tmux = require('utils.tmux')
  tmux.split_pane('horizontal', opts.args)
end, {
  nargs = '?',
  desc = 'Split tmux pane horizontally',
})

vim.api.nvim_create_user_command('TmuxSplitV', function(opts)
  local tmux = require('utils.tmux')
  tmux.split_pane('vertical', opts.args)
end, {
  nargs = '?',
  desc = 'Split tmux pane vertically',
})

vim.api.nvim_create_user_command('TmuxPanes', function()
  local tmux = require('utils.tmux')
  local panes = tmux.get_nvim_panes()

  -- Create a new scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('buftype', 'nofile', {
    buf = buf,
  })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', {
    buf = buf,
  })
  vim.api.nvim_set_option_value('swapfile', false, {
    buf = buf,
  })
  vim.api.nvim_buf_set_name(buf, 'Tmux Nvim Panes')

  -- Prepare content
  local lines = {}
  if #panes == 0 then
    table.insert(lines, 'No other nvim instances found in this tmux session')
    table.insert(lines, '')
    table.insert(lines, 'Press q to close this window')
  else
    table.insert(lines, 'Found ' .. #panes .. ' nvim instances in this session:')
    table.insert(lines, '')
    for i, pane in ipairs(panes) do
      table.insert(lines, string.format('%d: %s - %s', i, pane.id, pane.command))
    end
    table.insert(lines, '')
    table.insert(lines, 'Press q to close this window')
    table.insert(lines, 'Press <Enter> on a line to switch to that pane')
  end

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', false, {
    buf = buf,
  })
  vim.api.nvim_set_option_value('readonly', true, {
    buf = buf,
  })

  -- Open in a split window
  vim.cmd('split')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_set_height(win, math.min(#lines + 2, 15))

  -- Set buffer-local keymaps
  vim.keymap.set('n', 'q', '<cmd>q<cr>', {
    buffer = buf,
    desc = 'Close pane list',
  })

  if #panes > 0 then
    vim.keymap.set('n', '<CR>', function()
      local line_num = vim.api.nvim_win_get_cursor(0)[1]
      -- Check if we're on a pane line (starts with a number)
      local line = vim.api.nvim_buf_get_lines(buf, line_num - 1, line_num, false)[1]
      local pane_num = line:match('^(%d+):')

      if pane_num then
        local pane_index = tonumber(pane_num)
        if pane_index and panes[pane_index] then
          tmux.switch_to_pane(panes[pane_index].id)
          vim.cmd('q') -- Close the pane list
        end
      end
    end, {
      buffer = buf,
      desc = 'Switch to selected pane',
    })
  end

  -- Set syntax highlighting
  vim.api.nvim_set_option_value('filetype', 'tmuxpanes', {
    buf = buf,
  })
end, {
  desc = 'List nvim panes in current tmux session',
})

-- ===== Configuration Management Commands =====

vim.api.nvim_create_user_command('ConfigReload', function() require('utils.reload').reload_config() end, {
  desc = 'Reload Neovim configuration',
})

-- ===== LSP Management Commands =====

vim.api.nvim_create_user_command('LspRestart', function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    notify.warn('LSP', 'No clients running')
    return
  end

  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
    vim.lsp.stop_client(client.id, true)
  end

  notify.info('LSP', 'Stopped clients: ' .. table.concat(client_names, ', '))

  -- Restart LSP after a short delay
  vim.defer_fn(function()
    vim.cmd('LspStart')
    notify.success('LSP', 'Clients restarted')
  end, 1000)
end, {
  desc = 'Restart all LSP clients',
})

vim.api.nvim_create_user_command('LspStop', function(opts)
  local server_name = opts.args
  if server_name and server_name ~= '' then
    -- Stop specific server
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
      if client.name == server_name then
        vim.lsp.stop_client(client.id, true)
        notify.info('LSP', 'Stopped client: ' .. server_name)
        return
      end
    end
    notify.warn('LSP', 'Client not found: ' .. server_name)
  else
    -- Stop all servers
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
      notify.warn('LSP', 'No clients running')
      return
    end

    for _, client in ipairs(clients) do
      vim.lsp.stop_client(client.id, true)
    end
    notify.info('LSP', 'Stopped all clients')
  end
end, {
  nargs = '?',
  desc = 'Stop LSP client(s)',
})

vim.api.nvim_create_user_command('LspInfo', function()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    notify.info('LSP', 'No clients running')
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local buf_clients = vim.lsp.get_clients({
    bufnr = buf,
  })

  print('=== LSP Client Information ===')
  print('Buffer: ' .. vim.api.nvim_buf_get_name(buf))
  print('Filetype: ' .. vim.bo[buf].filetype)
  print('')

  if #buf_clients > 0 then
    print('Attached to current buffer:')
    for _, client in ipairs(buf_clients) do
      print('  • ' .. client.name .. ' (ID: ' .. client.id .. ')')
      if client.config.root_dir then print('    Root: ' .. client.config.root_dir) end
      -- Show capabilities for debugging
      local caps = client.server_capabilities
      if client.name == 'cssls' and vim.bo[buf].filetype == 'html' then
        print('    CSS in HTML capabilities:')
        print('      - Completion: ' .. tostring(caps.completionProvider and caps.completionProvider ~= nil))
        print('      - Hover: ' .. tostring(caps.hoverProvider and caps.hoverProvider or false))
        print('      - Definition: ' .. tostring(caps.definitionProvider and caps.definitionProvider or false))
      end
    end
    print('')
  else
    print('No LSP clients attached to current buffer')
    if vim.bo[buf].filetype == 'html' then
      print('Expected for HTML: superhtml, tailwindcss')
    elseif vim.tbl_contains({ 'css', 'scss', 'less' }, vim.bo[buf].filetype) then
      print('Expected for CSS: cssls')
    end
    print('')
  end

  print('All active clients:')
  for _, client in ipairs(clients) do
    local attached = vim.tbl_contains(buf_clients, client) and ' [ATTACHED]' or ''
    print('  • ' .. client.name .. ' (ID: ' .. client.id .. ')' .. attached)
  end
end, {
  desc = 'Show LSP client information',
})

-- ===== Buffer Debug Commands =====

vim.api.nvim_create_user_command('BufDebug', function()
  print('=== Buffer Debug Info ===')
  print('Arguments count: ' .. vim.fn.argc())
  print('Current working directory: ' .. vim.fn.getcwd())
  print('')

  local buffers = vim.api.nvim_list_bufs()
  print('Total buffers: ' .. #buffers)
  print('')

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      local bufname = vim.api.nvim_buf_get_name(buf)
      local buftype = vim.api.nvim_get_option_value('buftype', {
        buf = buf,
      })
      local filetype = vim.api.nvim_get_option_value('filetype', {
        buf = buf,
      })
      local loaded = vim.api.nvim_buf_is_loaded(buf)
      local listed = vim.api.nvim_get_option_value('buflisted', {
        buf = buf,
      })

      print(string.format('Buffer %d:', buf))
      print(string.format('  Name: %s', bufname ~= '' and bufname or '[No Name]'))
      print(string.format('  Type: %s', buftype ~= '' and buftype or 'normal'))
      print(string.format('  Filetype: %s', filetype ~= '' and filetype or 'none'))
      print(string.format('  Loaded: %s', loaded))
      print(string.format('  Listed: %s', listed))
      print('')
    end
  end
end, {
  desc = 'Debug buffer information',
})

-- ===== Session Management Commands =====

vim.api.nvim_create_user_command('SessionCheck', function()
  local session_utils = require('utils.session')

  print('=== Session Utility Status ===')
  print('')

  -- Check Lazy status
  local has_lazy_pending = session_utils.has_pending_lazy_operations()
  print('Lazy pending operations: ' .. (has_lazy_pending and 'YES' or 'NO'))

  -- Check Mason status
  local has_mason_pending = session_utils.has_pending_mason_installations()
  print('Mason pending installations: ' .. (has_mason_pending and 'YES' or 'NO'))

  -- Overall recommendation
  local action = session_utils.get_post_session_action()
  print('')
  print('Recommended post-session action: ' .. (action or 'NONE'))

  if action then
    notify.info('Session Check', 'Recommended action: ' .. action)
  else
    notify.success('Session Check', 'No pending operations detected')
  end
end, {
  desc = 'Check session utility status and pending operations',
})

vim.api.nvim_create_user_command('SessionOpenLazy', function()
  vim.cmd('Lazy')
  notify.info('Session', 'Manually opened Lazy')
end, {
  desc = 'Manually open Lazy (for testing session behavior)',
})

vim.api.nvim_create_user_command('SessionOpenMason', function()
  vim.cmd('Mason')
  notify.info('Session', 'Manually opened Mason')
end, {
  desc = 'Manually open Mason (for testing session behavior)',
})

-- ===== LSP Debug Commands =====

vim.api.nvim_create_user_command('LspDebug', function()
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({
    bufnr = buf,
  })

  print('=== LSP Debug Information ===')
  print('Buffer: ' .. vim.api.nvim_buf_get_name(buf))
  print('Filetype: ' .. vim.bo[buf].filetype)
  print('Working Directory: ' .. vim.fn.getcwd())
  print('')

  if #clients == 0 then
    print('No LSP clients attached to current buffer')
  else
    print('Attached clients:')
    for _, client in ipairs(clients) do
      print('  • ' .. client.name .. ' (ID: ' .. client.id .. ')')
      print('    Root: ' .. (client.config.root_dir or 'N/A'))
      print('    Autostart: ' .. tostring(client.config.autostart))
      print('    Cmd: ' .. (client.config.cmd and table.concat(client.config.cmd, ' ') or 'N/A'))
    end
  end

  print('')
  print('Deno project check:')
  local deno_files = { 'deno.json', 'deno.jsonc', 'deps.ts', 'import_map.json' }
  local is_deno_project = false
  for _, file in ipairs(deno_files) do
    local file_path = vim.fn.getcwd() .. '/' .. file
    if vim.fn.filereadable(file_path) == 1 then
      print('  ✓ Found: ' .. file)
      is_deno_project = true
    end
  end
  if not is_deno_project then print('  ✗ No Deno project files found') end

  print('')
  print('All LSP clients:')
  local all_clients = vim.lsp.get_clients()
  for _, client in ipairs(all_clients) do
    local attached = vim.tbl_contains(clients, client) and ' [ATTACHED]' or ''
    print('  • ' .. client.name .. ' (ID: ' .. client.id .. ')' .. attached)
  end
end, {
  desc = 'Debug LSP client information and conflicts',
})

-- Command to force restart LSP for current buffer
vim.api.nvim_create_user_command('LspRestartBuffer', function()
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({
    bufnr = buf,
  })

  if #clients == 0 then
    notify.warn('LSP', 'No clients attached to current buffer')
    return
  end

  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
    vim.lsp.stop_client(client.id, true)
  end

  notify.info('LSP', 'Stopped clients: ' .. table.concat(client_names, ', '))

  -- Restart LSP after a short delay
  vim.defer_fn(function()
    vim.cmd('LspStart')
    notify.success('LSP', 'Clients restarted for current buffer')
  end, 1000)
end, {
  desc = 'Restart LSP clients for current buffer only',
})

-- Deno support removed
