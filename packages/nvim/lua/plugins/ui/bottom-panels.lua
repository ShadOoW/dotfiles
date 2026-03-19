-- bottom-panels.lua: Register and manage bottom panels (noice, trouble, outputpanel, terminal)
-- Uses panel-manager for exclusive panel behavior: only one panel open at a time
local function setup()
  local pm = require('plugins.ui.panel-manager')
  local keymap = require('utils.keymap')

  -- Open trouble in a given mode, routing through the panel-manager so competing
  -- panels (noice, output-panel, etc.) are closed first.
  -- For diagnostic modes, also trigger lazy workspace-diagnostics population so
  -- the panel shows project-wide errors, not just currently-open buffers.
  local function trouble_toggle(mode)
    local trouble = require('trouble')
    local is_diag_mode = mode == 'cascade' or mode == 'diagnostics'
    if is_diag_mode then
      require('lsp.handlers').populate_workspace_diagnostics_for_buf()
    end
    if trouble.is_open() then
      trouble.toggle({ mode = mode })
    else
      pm.open_with('trouble', function() trouble.open({ mode = mode }) end)
    end
  end

  -- Find a non-floating (split) window showing the given filetype.
  local function find_split_win(ft)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == ft and vim.api.nvim_win_get_config(win).relative == '' then return win end
      end
    end
  end

  -- Find any window (split or float) showing the given filetype.
  local function find_any_win(ft)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == ft then return win end
      end
    end
  end

  -- ── Noice panel ─────────────────────────────────────────────────────────────
  -- Always delegate to noice.cmd('history') — noice manages its own split and
  -- refreshes content on every call.
  pm.register({
    ft = 'noice',
    open = function()
      require('noice').cmd('history')
    end,
    close = function()
      local win = find_split_win('noice')
      if win then vim.api.nvim_win_close(win, true) end
    end,
    is_open = function() return find_split_win('noice') ~= nil end,
  })

  -- ── Trouble panel ────────────────────────────────────────────────────────────
  pm.register({
    ft = 'trouble',
    open = function() require('trouble').open({ mode = 'cascade' }) end,
    close = function() require('trouble').close() end,
    is_open = function() return require('trouble').is_open() end,
  })

  -- ── LSP output panel ────────────────────────────────────────────────────────
  -- The plugin (mhanberg/output-panel.nvim) sometimes creates the buffer with no
  -- filetype and no name when there is no LSP output yet. We cache the buffer
  -- handle on first open so subsequent is_open() / close() calls still work.
  local _outputpanel_buf = nil

  local function find_outputpanel_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        -- Match by filetype, buffer name, or our cached handle
        local ft = vim.bo[buf].filetype
        local name = vim.api.nvim_buf_get_name(buf)
        if
          ft == 'outputpanel'
          or name:match('[Oo]utput[%-_ ]?[Pp]anel')
          or (_outputpanel_buf and buf == _outputpanel_buf)
        then
          return win
        end
      end
    end
  end

  -- Returns true if the outputpanel buffer has any non-whitespace content.
  local function outputpanel_has_content()
    -- Prefer the cached handle; otherwise scan all buffers
    local candidates = _outputpanel_buf and { _outputpanel_buf } or vim.api.nvim_list_bufs()
    for _, buf in ipairs(candidates) do
      if vim.api.nvim_buf_is_valid(buf) then
        local ft = vim.bo[buf].filetype
        local name = vim.api.nvim_buf_get_name(buf)
        if ft == 'outputpanel' or name:match('[Oo]utput[%-_ ]?[Pp]anel') or buf == _outputpanel_buf then
          _outputpanel_buf = buf
          for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
            if line:match('%S') then return true end
          end
          return false -- buffer found but empty
        end
      end
    end
    return false -- no buffer at all → no output yet
  end

  pm.register({
    ft = 'outputpanel',
    open = function()
      if find_outputpanel_win() then return end

      if not outputpanel_has_content() then
        require('utils.notify').info('Output Panel', 'No LSP output yet')
        return
      end

      -- Snapshot current windows so we can detect the new one
      local wins_before = {}
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        wins_before[w] = true
      end

      vim.cmd('OutputPanel')

      -- After the command runs, tag the new window's buffer so we can find it
      vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if not wins_before[win] then
            local buf = vim.api.nvim_win_get_buf(win)
            _outputpanel_buf = buf
            -- Also force filetype so lualine shows a proper name
            if vim.bo[buf].filetype == '' then vim.bo[buf].filetype = 'outputpanel' end
            break
          end
        end
      end)
    end,
    close = function()
      local win = find_outputpanel_win()
      if win then vim.api.nvim_win_close(win, true) end
    end,
    is_open = function() return find_outputpanel_win() ~= nil end,
  })

  -- ── LSP status panel ─────────────────────────────────────────────────────────
  -- Content is generated from the perspective of whichever buffer was active
  -- when the panel was toggled open (not the lspstatus panel itself).
  local function lsp_status_lines(source_buf)
    local ft = vim.bo[source_buf].filetype
    local buf_clients = vim.lsp.get_clients({ bufnr = source_buf })
    local all_clients = vim.lsp.get_clients()
    local rules = require('lsp.servers-list').filetype_rules[ft] or {}
    local expected = rules.expected or {}
    local forbidden = rules.forbidden or {}
    local attached_names = vim.tbl_map(function(c) return c.name end, buf_clients)

    local lines = {}
    local function line(s) table.insert(lines, s) end

    line(
      'LSP Status  —  '
        .. (ft ~= '' and ft or '[no filetype]')
        .. '  ('
        .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(source_buf), ':~:.')
        .. ')'
    )
    line(string.rep('─', 70))

    if #expected > 0 then
      line('EXPECTED')
      for _, name in ipairs(expected) do
        local c = nil
        for _, client in ipairs(buf_clients) do
          if client.name == name then
            c = client
            break
          end
        end
        if c then
          line(('  ✓  %-20s  attached   root: %s'):format(name, c.config.root_dir or 'N/A'))
        else
          line(('  ✗  %-20s  NOT ATTACHED'):format(name))
        end
      end
      line('')
    end

    line('ATTACHED TO BUFFER')
    if #buf_clients == 0 then
      line('  (none)')
    else
      for _, c in ipairs(buf_clients) do
        local tag = vim.tbl_contains(forbidden, c.name) and 'FORBIDDEN'
          or vim.tbl_contains(expected, c.name) and 'expected'
          or 'extra'
        line(('  •  %-20s  %-10s  id:%d  root: %s'):format(c.name, tag, c.id, c.config.root_dir or 'N/A'))
      end
    end
    line('')

    if #forbidden > 0 then
      local ok_forbidden = vim.tbl_filter(function(n) return not vim.tbl_contains(attached_names, n) end, forbidden)
      local bad_forbidden = vim.tbl_filter(function(n) return vim.tbl_contains(attached_names, n) end, forbidden)
      if #ok_forbidden > 0 then
        line('FORBIDDEN (not running — good)')
        for _, n in ipairs(ok_forbidden) do
          line(('  ✓  %s'):format(n))
        end
        line('')
      end
      if #bad_forbidden > 0 then
        line('FORBIDDEN (running — :LspStop <name> to remove)')
        for _, n in ipairs(bad_forbidden) do
          line(('  ✗  %s'):format(n))
        end
        line('')
      end
    end

    line('ALL ACTIVE CLIENTS')
    if #all_clients == 0 then
      line('  (none)')
    else
      for _, c in ipairs(all_clients) do
        local here = vim.tbl_contains(attached_names, c.name) and '  [this buf]' or ''
        line(('  •  %s  (id:%d)%s'):format(c.name, c.id, here))
      end
    end
    line('')
    line('  r  refresh   q  close')
    return lines
  end

  -- Find or create the persistent lspstatus scratch buffer.
  local function get_lsp_status_buf()
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) and vim.bo[b].filetype == 'lspstatus' then return b end
    end
    local b = vim.api.nvim_create_buf(false, true)
    vim.bo[b].filetype = 'lspstatus'
    vim.bo[b].bufhidden = 'hide'
    return b
  end

  pm.register({
    ft = 'lspstatus',
    title = 'LSP Status',
    open = function()
      -- Capture the source buffer before opening the split.
      local source_buf = vim.api.nvim_get_current_buf()
      local sbuf = get_lsp_status_buf()
      local lines = lsp_status_lines(source_buf)

      vim.api.nvim_set_option_value('modifiable', true, { buf = sbuf })
      vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, lines)
      vim.api.nvim_set_option_value('modifiable', false, { buf = sbuf })

      local win = vim.api.nvim_open_win(sbuf, false, {
        split = 'below',
        height = math.min(#lines + 1, 20),
      })
      vim.wo[win].number = false
      vim.wo[win].relativenumber = false
      vim.wo[win].signcolumn = 'no'
      vim.wo[win].wrap = false
      vim.wo[win].winbar = ''

      -- Refresh content (uses whichever non-lspstatus buffer is current)
      vim.keymap.set('n', 'r', function()
        local sb = vim.api.nvim_get_current_buf()
        for _, w in ipairs(vim.api.nvim_list_wins()) do
          local wb = vim.api.nvim_win_get_buf(w)
          if vim.bo[wb].filetype ~= 'lspstatus' then
            sb = wb
            break
          end
        end
        local new_lines = lsp_status_lines(sb)
        vim.api.nvim_set_option_value('modifiable', true, { buf = sbuf })
        vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, new_lines)
        vim.api.nvim_set_option_value('modifiable', false, { buf = sbuf })
      end, { buffer = sbuf, desc = 'Refresh LSP status' })

      vim.keymap.set(
        'n',
        'q',
        function() pm.toggle('lspstatus') end,
        { buffer = sbuf, desc = 'Close LSP status panel' }
      )
    end,
    close = function()
      local win = find_split_win('lspstatus')
      if win then vim.api.nvim_win_close(win, true) end
    end,
    is_open = function() return find_split_win('lspstatus') ~= nil end,
  })

  -- ── Terminal panel (toggleterm) ──────────────────────────────────────────────
  -- focus_panel=true: terminal takes focus so you can type immediately
  pm.register({
    ft = 'toggleterm',
    focus_panel = true,
    open = function() vim.cmd('ToggleTerm size=12 direction=horizontal') end,
    close = function()
      local win = find_any_win('toggleterm')
      if win then vim.api.nvim_win_close(win, true) end
    end,
    is_open = function() return find_any_win('toggleterm') ~= nil end,
  })

  pm.setup()

  -- output-panel.nvim hardcodes height=30; resize whenever its window appears.
  -- Also cache the buffer and force filetype if still empty.
  vim.api.nvim_create_autocmd('BufWinEnter', {
    callback = function(args)
      local buf = args.buf
      if not vim.api.nvim_buf_is_valid(buf) then return end
      local ft = vim.bo[buf].filetype
      local name = vim.api.nvim_buf_get_name(buf)
      -- Recognise by filetype or name, or if it matches our cached handle
      local is_op = ft == 'outputpanel'
        or name:match('[Oo]utput[%-_ ]?[Pp]anel')
        or (_outputpanel_buf and buf == _outputpanel_buf)
      if not is_op then return end

      _outputpanel_buf = buf
      if ft == '' then vim.bo[buf].filetype = 'outputpanel' end

      vim.schedule(function()
        local win = find_outputpanel_win()
        if win then vim.api.nvim_win_set_height(win, 12) end
      end)
    end,
  })

  -- ── Panel keybindings (<leader>x = panels only) ──────────────────────────────
  -- Trouble panels
  keymap.n('<leader>xd', function() trouble_toggle('cascade') end, 'Diagnostics panel')
  keymap.n('<leader>xq', function() trouble_toggle('qflist') end, 'Quickfix panel')
  keymap.n('<leader>xs', function() trouble_toggle('symbols') end, 'Symbols panel')
  -- Other panels
  keymap.n('<leader>xn', function() pm.toggle('noice') end, 'Notifications panel')
  keymap.n('<leader>xo', function() pm.toggle('outputpanel') end, 'LSP output panel')
  keymap.n('<leader>xt', function() pm.toggle('toggleterm') end, 'Terminal panel')
  keymap.n('<leader>xl', function() pm.toggle('lspstatus') end, 'LSP status panel')
end

return { setup = setup }
