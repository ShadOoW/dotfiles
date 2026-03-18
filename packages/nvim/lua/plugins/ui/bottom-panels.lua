-- bottom-panels.lua: Register and manage bottom panels (noice, trouble, outputpanel)
-- Uses panel-manager for exclusive panel behavior: only one panel open at a time
local function setup()
  local pm = require('plugins.ui.panel-manager')
  local keymap = require('utils.keymap')

  -- Find a non-floating (split) window showing the given filetype.
  -- Used for noice which also has floating mini-notification popups.
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

  pm.register({
    ft = 'noice',
    open = function() require('noice').cmd('history') end,
    close = function()
      local win = find_split_win('noice')
      if win then vim.api.nvim_win_close(win, true) end
    end,
    is_open = function() return find_split_win('noice') ~= nil end,
  })

  -- Trouble qflist panel — populated by <leader>xW (tsc --noEmit)
  -- NOTE: trouble.nvim v3 uses lowercase filetype 'trouble'
  pm.register({
    ft = 'trouble',
    open = function() require('trouble').open('qflist') end,
    close = function() require('trouble').close() end,
    is_open = function() return require('trouble').is_open() end,
  })

  -- LSP server output panel
  -- NOTE: plugin filetype is 'outputpanel' (no hyphen); height is hardcoded to 30
  -- in the plugin source — we override it via BufWinEnter below.
  pm.register({
    ft = 'outputpanel',
    open = function()
      if not find_any_win('outputpanel') then vim.cmd('OutputPanel') end
    end,
    close = function()
      local win = find_any_win('outputpanel')
      if win then vim.api.nvim_win_close(win, true) end
    end,
    is_open = function() return find_any_win('outputpanel') ~= nil end,
  })

  pm.setup()

  -- output-panel.nvim hardcodes height=30; resize to match other panels
  vim.api.nvim_create_autocmd('BufWinEnter', {
    callback = function(args)
      if vim.bo[args.buf].filetype ~= 'outputpanel' then return end
      vim.schedule(function()
        local win = find_any_win('outputpanel')
        if win then vim.api.nvim_win_set_height(win, 12) end
      end)
    end,
  })

  keymap.n('<leader>xn', function() pm.toggle('noice') end, 'Toggle notification panel')
  keymap.n('<leader>xw', function() pm.toggle('trouble') end, 'Toggle workspace diagnostics panel')
  keymap.n('<leader>xo', function() pm.toggle('outputpanel') end, 'Toggle LSP output panel')
  keymap.n('<leader>xX', function() pm.close_all() end, 'Close all bottom panels')
end

return { setup = setup }
