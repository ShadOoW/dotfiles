-- All user commands for Neovim configuration
-- Centralized command definitions
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
    vim.notify('No write since last change (add ! to override)', vim.log.levels.ERROR)
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
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
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
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'readonly', true)

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
  vim.api.nvim_buf_set_option(buf, 'filetype', 'tmuxpanes')
end, {
  desc = 'List nvim panes in current tmux session',
})

-- ===== Configuration Management Commands =====

vim.api.nvim_create_user_command('ConfigReload', function() require('utils.reload').reload_config() end, {
  desc = 'Reload Neovim configuration',
})

-- ===== Java/JDTLS Commands =====

vim.api.nvim_create_user_command('JdtlsRestart', function()
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    if client.name == 'jdtls' then
      vim.lsp.stop_client(client.id)
      vim.defer_fn(function() vim.cmd('LspStart jdtls') end, 1000)
      return
    end
  end
  vim.notify('JDTLS client not found', vim.log.levels.WARN)
end, {
  desc = 'Restart JDTLS language server',
})

vim.api.nvim_create_user_command('JdtlsCleanWorkspace', function()
  local workspace_path = vim.fn.expand('~/.cache/jdtls-workspace')
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  local workspace_dir = workspace_path .. '/' .. project_name

  if vim.fn.isdirectory(workspace_dir) == 1 then
    vim.fn.delete(workspace_dir, 'rf')
    vim.notify('Cleaned JDTLS workspace: ' .. workspace_dir, vim.log.levels.INFO)
    vim.cmd('JdtlsRestart')
  else
    vim.notify('Workspace directory not found: ' .. workspace_dir, vim.log.levels.WARN)
  end
end, {
  desc = 'Clean JDTLS workspace and restart',
})

vim.api.nvim_create_user_command('JdtlsCheckJava', function()
  local java_version = vim.fn.system('java -version 2>&1 | head -1')
  local java_home = vim.env.JAVA_HOME or 'Not set'
  local jdtls_root = vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls')

  vim.notify('Java Version: ' .. java_version:gsub('\n', ''), vim.log.levels.INFO)
  vim.notify('JAVA_HOME: ' .. java_home, vim.log.levels.INFO)
  vim.notify('JDTLS Root: ' .. jdtls_root, vim.log.levels.INFO)

  if vim.fn.isdirectory(jdtls_root) == 1 then
    vim.notify('JDTLS installation found', vim.log.levels.INFO)
  else
    vim.notify('JDTLS installation not found', vim.log.levels.ERROR)
  end
end, {
  desc = 'Check Java and JDTLS setup',
})

vim.api.nvim_create_user_command('JdtlsStatus', function()
  local clients = vim.lsp.get_active_clients()
  local jdtls_client = nil
  for _, client in ipairs(clients) do
    if client.name == 'jdtls' then
      jdtls_client = client
      break
    end
  end

  if jdtls_client then
    vim.notify('JDTLS Status: Active (ID: ' .. jdtls_client.id .. ')', vim.log.levels.INFO)
    vim.notify('Root Dir: ' .. (jdtls_client.config.root_dir or 'Unknown'), vim.log.levels.INFO)
  else
    vim.notify('JDTLS Status: Not running', vim.log.levels.WARN)
  end
end, {
  desc = 'Show JDTLS status',
})

vim.api.nvim_create_user_command('JdtlsDebugRoot', function()
  local root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' })
  vim.notify('Detected root directory: ' .. (root_dir or 'Not found'), vim.log.levels.INFO)
end, {
  desc = 'Debug JDTLS root directory detection',
})

-- ===== LSP Management Commands =====

vim.api.nvim_create_user_command('LspRestart', function(opts)
  local clients = vim.lsp.get_active_clients()
  if #clients == 0 then
    vim.notify('No LSP clients running', vim.log.levels.WARN)
    return
  end

  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
    vim.lsp.stop_client(client.id, true)
  end

  vim.notify('Stopped LSP clients: ' .. table.concat(client_names, ', '), vim.log.levels.INFO)

  -- Restart LSP after a short delay
  vim.defer_fn(function()
    vim.cmd('LspStart')
    vim.notify('LSP clients restarted', vim.log.levels.INFO)
  end, 1000)
end, {
  desc = 'Restart all LSP clients',
})

vim.api.nvim_create_user_command('LspStop', function(opts)
  local server_name = opts.args
  if server_name and server_name ~= '' then
    -- Stop specific server
    local clients = vim.lsp.get_active_clients()
    for _, client in ipairs(clients) do
      if client.name == server_name then
        vim.lsp.stop_client(client.id, true)
        vim.notify('Stopped LSP client: ' .. server_name, vim.log.levels.INFO)
        return
      end
    end
    vim.notify('LSP client not found: ' .. server_name, vim.log.levels.WARN)
  else
    -- Stop all servers
    local clients = vim.lsp.get_active_clients()
    if #clients == 0 then
      vim.notify('No LSP clients running', vim.log.levels.WARN)
      return
    end

    for _, client in ipairs(clients) do
      vim.lsp.stop_client(client.id, true)
    end
    vim.notify('Stopped all LSP clients', vim.log.levels.INFO)
  end
end, {
  nargs = '?',
  desc = 'Stop LSP client(s)',
})

vim.api.nvim_create_user_command('LspInfo', function()
  local clients = vim.lsp.get_active_clients()
  if #clients == 0 then
    vim.notify('No LSP clients running', vim.log.levels.INFO)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local buf_clients = vim.lsp.get_active_clients({
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
        print('      - Completion: ' .. tostring(caps.completionProvider ~= nil))
        print('      - Hover: ' .. tostring(caps.hoverProvider))
        print('      - Definition: ' .. tostring(caps.definitionProvider))
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
