-- bottom-panels.lua: Register and manage bottom panels (noice, trouble, outputpanel, terminal)
-- Uses panel-manager for exclusive panel behavior: only one panel open at a time
local function setup()
  local pm = require('plugins.ui.panel-manager')
  local keymap = require('utils.keymap')

  -- Find a non-floating (split) window showing the given filetype.
  local function find_split_win(ft)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == ft and vim.api.nvim_win_get_config(win).relative == '' then
          return win
        end
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
  -- We bypass noice.cmd('history') for re-opens: once the noice buffer exists we
  -- open it manually so the view always (re)appears even after a manual close.
  pm.register({
    ft = 'noice',
    open = function()
      -- Find the existing noice buffer (may be hidden after a previous close)
      local noice_buf = nil
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'noice' then
          noice_buf = buf
          break
        end
      end

      if noice_buf then
        -- Re-open in a bottom split without stealing focus (nvim_open_win enter=false)
        local win = vim.api.nvim_open_win(noice_buf, false, {
          split = 'below',
          height = 12,
        })
        vim.wo[win].number = false
        vim.wo[win].relativenumber = false
        vim.wo[win].signcolumn = 'no'
        vim.wo[win].wrap = true
        vim.wo[win].winbar = ''
        vim.wo[win].winhighlight = 'Normal:NoiceSplit,FloatBorder:NoiceSplitBorder'
      else
        -- First ever open — let noice create the buffer via its history command
        require('noice').cmd('history')
      end
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
    open = function() require('trouble').open('qflist') end,
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
        if ft == 'outputpanel'
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
      for _, w in ipairs(vim.api.nvim_list_wins()) do wins_before[w] = true end

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

  keymap.n('<leader>xn', function() pm.toggle('noice') end, 'Toggle notification panel')
  keymap.n('<leader>xw', function() pm.toggle('trouble') end, 'Toggle workspace diagnostics panel')
  keymap.n('<leader>xo', function() pm.toggle('outputpanel') end, 'Toggle LSP output panel')
  keymap.n('<leader>xt', function() pm.toggle('toggleterm') end, 'Toggle terminal')
  keymap.n('<leader>xX', function() pm.close_all() end, 'Close all bottom panels')
end

return { setup = setup }
