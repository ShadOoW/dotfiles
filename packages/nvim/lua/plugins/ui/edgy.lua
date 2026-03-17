-- edgy.nvim: Window layout manager for Neovim
-- Manages Noice and Trouble panels in bottom zone
return {
  'folke/edgy.nvim',
  event = 'VeryLazy',
  dependencies = { 'folke/noice.nvim', 'folke/trouble.nvim' },
  opts = {
    animate = true,
    -- Define the layout zones
    topbar = {
      -- Empty topbar
    },
    bottombar = {
      {
        -- Bottom panel: Noice OR Trouble (mutually exclusive, same zone)
        ft = { 'noice', 'Trouble' },
        title = function(win)
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft == 'noice' then
            return '󰎟  Notifications'
          elseif ft == 'Trouble' then
            return '  Problems'
          end
          return ''
        end,
        size = 15,
        filter = function(_, win)
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft ~= 'noice' and ft ~= 'Trouble' then return false end
          local config = vim.api.nvim_win_get_config(win)
          return config.relative == '' or config.relative == nil
        end,
      },
    },
    leftbar = {
      {
        -- Aerial in left zone
        ft = 'aerial',
        title = 'Aerial',
        size = 35,
        filter = function(_, win)
          local buf = vim.api.nvim_win_get_buf(win)
          return vim.bo[buf].filetype == 'aerial'
        end,
      },
    },
    rightbar = {
      -- Empty rightbar
    },
    -- Window options
    wo = {
      -- Status line shows counts
      statusline = {
        -- Show notification count for noice panel
        enabled = true,
        left = function(win)
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'noice' then
            local noice = require('noice')
            local count = 0
            -- Try to get notification count from noice API
            if noice and noice.status then
              local status = noice.status()
              if status and status.messages then
                count = #status.messages
              end
            end
            return string.format('%%#EdgyTitle#%s %%#Normal#%d notifications', '󰎟 ', count)
          elseif vim.bo[buf].filetype == 'Trouble' then
            -- Count errors and warnings from diagnostics
            local diags = vim.diagnostic.get(0)
            local errors = 0
            local warnings = 0
            for _, diag in ipairs(diags) do
              if diag.severity == vim.diagnostic.severity.ERROR then
                errors = errors + 1
              elseif diag.severity == vim.diagnostic.severity.WARN then
                warnings = warnings + 1
              end
            end
            return string.format('%%#EdgyTitle#%s %%#DiagnosticSignError#%d %%#DiagnosticSignWarn#%d', '  ', errors, warnings)
          end
          return ''
        end,
        right = function() return '' end,
      },
    },
    -- Keys for cycling between panels
    keys = {
      -- Custom keymaps will be added separately
    },
  },
  config = function(_, opts)
    local edgy = require('edgy')
    edgy.setup(opts)

    -- Define keymaps for edgy panels
    local keymap = require('utils.keymap')

    -- Function to toggle Noice notification panel (closes Trouble first)
    local function toggle_noice_panel()
      -- Close any Trouble panel first
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'Trouble' then
            local config = vim.api.nvim_win_get_config(win)
            if config and (config.relative == '' or config.relative == nil) then
              vim.api.nvim_win_close(win, true)
              break
            end
          end
        end
      end

      -- Check if noice panel is already open
      local noice_open = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'noice' then
            local config = vim.api.nvim_win_get_config(win)
            if config and (config.relative == '' or config.relative == nil) then
              noice_open = true
              vim.api.nvim_win_close(win, true)
              break
            end
          end
        end
      end

      if not noice_open then
        -- Open Noice history
        vim.cmd('NoiceHistory')
        -- Focus the noice window if it was just opened
        vim.defer_fn(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == 'noice' then
                local config = vim.api.nvim_win_get_config(win)
                if config and (config.relative == '' or config.relative == nil) then
                  vim.api.nvim_set_current_win(win)
                  break
                end
              end
            end
          end
        end, 50)
      end
    end

    -- Function to toggle Trouble workspace diagnostics (closes Noice first)
    local function toggle_trouble_panel()
      -- Close any Noice panel first
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'noice' then
            local config = vim.api.nvim_win_get_config(win)
            if config and (config.relative == '' or config.relative == nil) then
              vim.api.nvim_win_close(win, true)
              break
            end
          end
        end
      end

      -- Check if Trouble panel is already open
      local trouble_open = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'Trouble' then
            local config = vim.api.nvim_win_get_config(win)
            if config and (config.relative == '' or config.relative == nil) then
              trouble_open = true
              vim.api.nvim_win_close(win, true)
              break
            end
          end
        end
      end

      if not trouble_open then
        require('trouble').open('diagnostics')
      end
    end

    -- Function to cycle to next edgy panel in bottom zone
    local function edgy_next()
      local current_win = vim.api.nvim_get_current_win()
      local bottom_panels = { 'noice', 'Trouble' }
      local current_ft = vim.bo[vim.api.nvim_win_get_buf(current_win)].filetype

      -- Find current panel index
      local current_idx = -1
      for i, ft in ipairs(bottom_panels) do
        if ft == current_ft then
          current_idx = i
          break
        end
      end

      if current_idx == -1 then
        -- Not in a panel, open the first one
        toggle_noice_panel()
        return
      end

      -- Close current and open next
      vim.api.nvim_win_close(current_win, true)
      local next_idx = (current_idx % #bottom_panels) + 1
      if bottom_panels[next_idx] == 'noice' then
        toggle_noice_panel()
      else
        require('trouble').open('diagnostics')
      end
    end

    -- Function to cycle to previous edgy panel in bottom zone
    local function edgy_prev()
      local current_win = vim.api.nvim_get_current_win()
      local bottom_panels = { 'noice', 'Trouble' }
      local current_ft = vim.bo[vim.api.nvim_win_get_buf(current_win)].filetype

      -- Find current panel index
      local current_idx = -1
      for i, ft in ipairs(bottom_panels) do
        if ft == current_ft then
          current_idx = i
          break
        end
      end

      if current_idx == -1 then
        -- Not in a panel, open Trouble directly
        require('trouble').open('diagnostics')
        return
      end

      -- Close current and open previous
      vim.api.nvim_win_close(current_win, true)
      local prev_idx = current_idx - 1
      if prev_idx < 1 then
        prev_idx = #bottom_panels
      end
      if bottom_panels[prev_idx] == 'noice' then
        toggle_noice_panel()
      else
        require('trouble').open('diagnostics')
      end
    end

    -- Function to close all edgy panels
    local function close_all_edgy()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft == 'noice' or ft == 'Trouble' then
            local config = vim.api.nvim_win_get_config(win)
            if config and (config.relative == '' or config.relative == nil) then
              vim.api.nvim_win_close(win, true)
            end
          end
        end
      end
    end

    -- Register keymaps
    keymap.n('<leader>xn', toggle_noice_panel, 'Toggle Noice notification panel')
    keymap.n('<leader>xw', toggle_trouble_panel, 'Toggle Trouble workspace diagnostics')
    keymap.n('<leader>xj', edgy_next, 'Edgy next panel')
    keymap.n('<leader>xk', edgy_prev, 'Edgy previous panel')
    keymap.n('<leader>xo', close_all_edgy, 'Close all edgy panels')

    -- Auto-open Noice panel on startup
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = function()
        vim.defer_fn(function()
          toggle_noice_panel()
        end, 100)
      end,
    })
  end,
}
