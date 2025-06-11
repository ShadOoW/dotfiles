-- Enhanced tabline with better UI/UX
return {
  'nanozuki/tabby.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local theme = {
      fill = 'TabLineFill',
      head = 'TabLine',
      current_tab = 'TabLineSel',
      tab = 'TabLine',
      win = 'TabLine',
      tail = 'TabLine',
    }

    require('tabby.tabline').set(function(line)
      return {
        {
          {
            '  ',
            hl = theme.head,
          },
          line.sep('', theme.head, theme.fill),
        },
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and theme.current_tab or theme.tab
          return {
            line.sep('', hl, theme.fill),
            tab.is_current() and '' or '',
            tab.number(),
            tab.name(),
            tab.close_btn(''),
            line.sep('', hl, theme.fill),
            hl = hl,
            margin = ' ',
          }
        end),
        line.spacer(),
        line.wins_in_tab(line.api.get_current_tab()).foreach(
          function(win)
            return {
              line.sep('', theme.win, theme.fill),
              win.is_current() and '' or '',
              win.buf_name(),
              line.sep('', theme.win, theme.fill),
              hl = theme.win,
              margin = ' ',
            }
          end
        ),
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
        vim.notify('Only one tab open', vim.log.levels.INFO)
        return
      end

      local choices = {}
      for i, tab in ipairs(tabs) do
        local current = vim.api.nvim_get_current_tabpage() == tab
        local marker = current and '▶ ' or '  '
        local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab)))
        local name = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or '[No Name]'
        table.insert(choices, marker .. tostring(i) .. ': ' .. name)
      end

      vim.ui.select(choices, {
        prompt = 'Select tab:',
        format_item = function(item) return item end,
      }, function(choice, idx)
        if choice and idx then vim.api.nvim_set_current_tabpage(tabs[idx]) end
      end)
    end, {
      desc = 'Tab Selector',
    })

    -- Quick tab switching with numbers
    for i = 1, 9 do
      vim.keymap.set('n', '<leader>' .. i, function()
        local tabs = vim.api.nvim_list_tabpages()
        if tabs[i] then
          vim.api.nvim_set_current_tabpage(tabs[i])
        else
          vim.notify('Tab ' .. i .. ' does not exist', vim.log.levels.WARN)
        end
      end, {
        desc = 'Go to tab ' .. i,
      })
    end
  end,
}
