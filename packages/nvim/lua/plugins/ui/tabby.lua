-- Enhanced tabline with Tokyo Night theme integration
return {
  'nanozuki/tabby.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    -- Get Tokyo Night colors
    local function get_tokyonight_colors()
      local colors = require('tokyonight.colors').setup({
        style = 'night',
      })
      return colors
    end

    -- Custom theme with Tokyo Night colors
    local c = get_tokyonight_colors()

    -- Define custom highlight groups for better tab appearance
    vim.api.nvim_set_hl(0, 'TabbyCurrentTab', {
      bg = c.blue,
      fg = c.bg_dark,
      bold = true,
    })

    vim.api.nvim_set_hl(0, 'TabbyInactiveTab', {
      bg = 'NONE',
      fg = c.fg_gutter,
    })

    vim.api.nvim_set_hl(0, 'TabbyTabSeparator', {
      bg = 'NONE',
      fg = c.blue2,
    })

    vim.api.nvim_set_hl(0, 'TabbyCurrentWin', {
      bg = c.purple,
      fg = c.bg_dark,
      bold = true,
    })

    vim.api.nvim_set_hl(0, 'TabbyInactiveWin', {
      bg = 'NONE',
      fg = c.fg_dark,
    })

    vim.api.nvim_set_hl(0, 'TabbyFill', {
      bg = 'NONE',
      fg = c.fg_gutter,
    })

    -- Enhanced theme configuration
    local theme = {
      fill = 'TabbyFill',
      head = 'TabbyInactiveTab',
      current_tab = 'TabbyCurrentTab',
      tab = 'TabbyInactiveTab',
      win = 'TabbyInactiveWin',
      current_win = 'TabbyCurrentWin',
      tail = 'TabbyInactiveTab',
    }

    require('tabby.tabline').set(function(line)
      return {
        -- Left section with logo
        {
          {
            '  ',
            hl = theme.head,
          },
          line.sep('', theme.head, theme.fill),
        },

        -- Tabs section
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and theme.current_tab or theme.tab
          local icon = tab.is_current() and ' ' or ' '
          local close_icon = tab.is_current() and ' ' or ' '

          return {
            line.sep('', hl, theme.fill),
            {
              icon,
              hl = hl,
            },
            {
              ' ' .. tab.number() .. ' ',
              hl = hl,
            },
            {
              tab.name(),
              hl = hl,
            },
            {
              close_icon,
              hl = hl,
            },
            line.sep('', hl, theme.fill),
            hl = hl,
            margin = '',
          }
        end),

        -- Spacer
        line.spacer(),

        -- Windows section (buffers in current tab)
        line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
          local hl = win.is_current() and theme.current_win or theme.win
          local icon = win.is_current() and ' ' or ' '

          -- Get file icon
          local buf_name = win.buf_name()
          local file_name = buf_name ~= '' and vim.fn.fnamemodify(buf_name, ':t') or '[No Name]'
          local file_icon = ''

          -- Try to get file icon from nvim-web-devicons
          local ok, devicons = pcall(require, 'nvim-web-devicons')
          if ok and buf_name ~= '' then
            local ext = vim.fn.fnamemodify(buf_name, ':e')
            local icon_char, _ = devicons.get_icon(file_name, ext, {
              default = true,
            })
            if icon_char then file_icon = icon_char .. ' ' end
          end

          return {
            line.sep('', hl, theme.fill),
            {
              icon,
              hl = hl,
            },
            {
              ' ' .. file_icon .. file_name .. ' ',
              hl = hl,
            },
            line.sep('', hl, theme.fill),
            hl = hl,
            margin = '',
          }
        end),

        -- Right section
        {
          line.sep('', theme.tail, theme.fill),
          {
            '  ',
            hl = theme.tail,
          },
        },

        hl = theme.fill,
      }
    end)

    -- Enhanced keybindings for tab navigation with visual indicators
    vim.keymap.set('n', '<leader>tt', function()
      -- Create a floating menu for tab selection
      local tabs = vim.api.nvim_list_tabpages()
      if #tabs <= 1 then
        vim.notify('Only one tab open', vim.log.levels.INFO, {
          title = 'Tab Navigation',
        })
        return
      end

      local choices = {}
      for i, tab in ipairs(tabs) do
        local current = vim.api.nvim_get_current_tabpage() == tab
        local marker = current and ' ' or ' '
        local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab)))
        local name = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No Name]'

        -- Get file icon
        local file_icon = ''
        local ok, devicons = pcall(require, 'nvim-web-devicons')
        if ok and bufname ~= '' then
          local ext = vim.fn.fnamemodify(bufname, ':e')
          local icon_char, _ = devicons.get_icon(name, ext, {
            default = true,
          })
          if icon_char then file_icon = icon_char .. ' ' end
        end

        table.insert(choices, marker .. ' ' .. tostring(i) .. ': ' .. file_icon .. name)
      end

      vim.ui.select(choices, {
        prompt = ' Select tab:',
        format_item = function(item) return item end,
      }, function(choice, idx)
        if choice and idx then
          vim.api.nvim_set_current_tabpage(tabs[idx])
          vim.notify('Switched to tab ' .. idx, vim.log.levels.INFO, {
            title = 'Tab Navigation',
          })
        end
      end)
    end, {
      desc = 'Tab Selector with Icons',
    })

    -- Quick tab switching with numbers (enhanced with notifications)
    for i = 1, 9 do
      vim.keymap.set('n', '<leader>' .. i, function()
        local tabs = vim.api.nvim_list_tabpages()
        if tabs[i] then
          vim.api.nvim_set_current_tabpage(tabs[i])
          vim.notify('Switched to tab ' .. i, vim.log.levels.INFO, {
            title = 'Tab Navigation',
          })
        else
          vim.notify('Tab ' .. i .. ' does not exist', vim.log.levels.WARN, {
            title = 'Tab Navigation',
          })
        end
      end, {
        desc = 'Go to tab ' .. i,
      })
    end

    -- Additional tab management keybindings
    vim.keymap.set('n', '<leader>tR', function()
      -- Rename current tab
      local current_tab = vim.api.nvim_get_current_tabpage()
      local current_name = vim.fn.gettabvar(current_tab, 'tabby_name', '')

      vim.ui.input({
        prompt = 'Tab name: ',
        default = current_name,
      }, function(name)
        if name and name ~= '' then
          vim.api.nvim_tabpage_set_var(current_tab, 'tabby_name', name)
          vim.notify('Tab renamed to: ' .. name, vim.log.levels.INFO, {
            title = 'Tab Management',
          })
        end
      end)
    end, {
      desc = 'Rename current tab',
    })
  end,
}
