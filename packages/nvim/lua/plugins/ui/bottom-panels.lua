-- bottom-panels.lua: Register and manage bottom panels (noice, trouble)
-- Uses panel-manager for exclusive panel behavior
local function setup()
  local pm = require('plugins.ui.panel-manager')
  local keymap = require('utils.keymap')

  -- Helper: find a non-floating window showing the given filetype
  local function find_panel_win(ft)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == ft then
          local cfg = vim.api.nvim_win_get_config(win)
          if cfg.relative == '' then
            return win
          end
        end
      end
    end
  end

  -- Noice panel
  pm.register({
    ft = 'noice',
    open = function()
      vim.cmd('NoiceHistory')
    end,
    close = function()
      local win = find_panel_win('noice')
      if win then vim.api.nvim_win_close(win, true) end
    end,
    is_open = function()
      return find_panel_win('noice') ~= nil
    end,
  })

  -- Trouble panel
  pm.register({
    ft = 'Trouble',
    open = function()
      require('trouble').open('diagnostics')
    end,
    close = function()
      require('trouble').close()
    end,
    is_open = function()
      return require('trouble').is_open()
    end,
  })

  -- Hook BufWinEnter for auto-opens (e.g. noice on notification)
  pm.setup()

  keymap.n('<leader>xn', function() pm.toggle('noice') end, 'Toggle Noice notification panel')
  keymap.n('<leader>xw', function() pm.toggle('Trouble') end, 'Toggle Trouble workspace diagnostics')
  keymap.n('<leader>xo', function() pm.close_all() end, 'Close all bottom panels')
end

return {
  setup = setup,
}
