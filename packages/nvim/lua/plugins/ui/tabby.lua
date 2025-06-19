-- Modern tabline with Tokyo Night theme integration and custom naming
return {
  'nanozuki/tabby.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    -- Get Tokyo Night colors
    local function get_tokyonight_colors()
      local ok, colors = pcall(require, 'tokyonight.colors')
      if ok then
        return colors.setup({
          style = 'night',
        })
      else
        -- Fallback colors in case Tokyo Night is not available
        return {
          bg_dark = '#1a1b26',
          bg = '#24283b',
          fg = '#c0caf5',
          fg_dark = '#737aa2',
          blue = '#7aa2f7',
          blue0 = '#3d59a1',
          purple = '#bb9af7',
          cyan = '#7dcfff',
          green = '#9ece6a',
          red = '#f7768e',
          orange = '#ff9e64',
          yellow = '#e0af68',
        }
      end
    end

    local c = get_tokyonight_colors()

    -- Define custom highlight groups for modern tabline
    vim.api.nvim_set_hl(0, 'TabbyCurrentTab', {
      bg = c.blue,
      fg = c.bg_dark,
      bold = true,
    })

    vim.api.nvim_set_hl(0, 'TabbyCurrentTabSep', {
      bg = c.bg_dark,
      fg = c.blue,
    })

    vim.api.nvim_set_hl(0, 'TabbyInactiveTab', {
      bg = c.bg,
      fg = c.fg_dark,
    })

    vim.api.nvim_set_hl(0, 'TabbyInactiveTabSep', {
      bg = c.bg_dark,
      fg = c.bg,
    })

    vim.api.nvim_set_hl(0, 'TabbyTabLine', {
      bg = c.bg_dark,
      fg = c.fg_dark,
    })

    vim.api.nvim_set_hl(0, 'TabbyModified', {
      bg = c.orange,
      fg = c.bg_dark,
      bold = true,
    })

    -- Helper function to get custom tab name for trouble and other special buffers
    local function get_custom_tab_name(tab)
      -- Get the current window in the tab
      local current_win = tab.current_win()
      if not current_win then return 'Tab ' .. tab.number() end

      -- Get the buffer from the window
      local buf = current_win.buf()
      if not buf then return 'Tab ' .. tab.number() end

      local buf_name = buf.name()
      local buf_type = buf.type()

      -- Handle special buffer types
      if buf_type == 'nofile' or buf_type == 'terminal' then
        -- Check for trouble buffers (fallback if title not set)
        if buf_name:match('^trouble://') then
          -- Extract trouble type from the buffer name
          local trouble_type = buf_name:match('^trouble://([^/]+)')
          if trouble_type then
            local type_map = {
              diagnostics = ' Diagnostics',
              quickfix = ' Quickfix',
              loclist = ' Location List',
              lsp_references = ' References',
              lsp_definitions = ' Definitions',
              lsp_type_definitions = ' Type Defs',
              lsp_implementations = ' Implementations',
              lsp_document_symbols = ' Symbols',
              lsp_workspace_symbols = ' Workspace',
            }
            return type_map[trouble_type] or (' ' .. trouble_type:gsub('_', ' '):gsub('^%l', string.upper))
          end
          return ' Trouble'
        end

        -- Handle terminal buffers
        if buf_name:match('^term://') then return ' Terminal' end

        -- Handle other special buffers
        local special_names = {
          ['NvimTree'] = ' Files',
          ['neo-tree'] = ' Files',
          ['aerial'] = ' Outline',
          ['Outline'] = ' Outline',
          ['dapui_'] = ' Debug',
          ['dap-repl'] = ' Debug REPL',
          ['gitcommit'] = ' Git Commit',
          ['fugitive://'] = ' Git',
          ['DiffviewFiles'] = ' Git Diff',
          ['NeogitStatus'] = ' Git Status',
        }

        for pattern, name in pairs(special_names) do
          if buf_name:find(pattern) then return name end
        end
      end

      -- For normal files, use a shortened version of the buffer name
      if buf_name and buf_name ~= '' then
        local file_name = vim.fn.fnamemodify(buf_name, ':t')
        if file_name == '' then file_name = 'No Name' end
        -- Add file icon if available
        local ok, devicons = pcall(require, 'nvim-web-devicons')
        if ok then
          local icon, _ = devicons.get_icon(file_name, vim.fn.fnamemodify(buf_name, ':e'), {
            default = true,
          })
          if icon then return icon .. ' ' .. file_name end
        end
        return file_name
      end

      return 'Tab ' .. tab.number()
    end

    -- Set up the tabline
    require('tabby.tabline').set(function(line)
      return {
        -- Left padding
        {
          '  ',
          hl = 'TabbyTabLine',
        },
        -- Tabs
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and 'TabbyCurrentTab' or 'TabbyInactiveTab'
          local sep_hl = tab.is_current() and 'TabbyCurrentTabSep' or 'TabbyInactiveTabSep'
          local custom_name = get_custom_tab_name(tab)

          -- Check if tab has modified buffers
          local has_modified = false
          local wins = tab.wins()
          if wins then
            for _, win in ipairs(wins) do
              local buf = win.buf()
              if buf and buf.is_changed() then
                has_modified = true
                break
              end
            end
          end

          return {
            line.sep('', sep_hl, 'TabbyTabLine'),
            {
              ' ',
              tab.is_current() and '' or '',
              ' ',
              tab.number(),
              ' ',
              custom_name,
              has_modified and ' ●' or '',
              ' ',
              hl = hl,
            },
            line.sep('', sep_hl, 'TabbyTabLine'),
            margin = '',
          }
        end),
        -- Spacer to push right content to the right
        line.spacer(),
        -- Right side info (optional)
        {
          -- Current working directory
          ' '
            .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            .. ' ',
          hl = 'TabbyTabLine',
        },
        -- Right padding
        {
          '  ',
          hl = 'TabbyTabLine',
        },
        hl = 'TabbyTabLine',
      }
    end)

    -- Enhanced keybindings for tab navigation
    local keymap = vim.keymap.set

    -- Tab navigation with notifications
    keymap('n', '<leader>tt', function()
      local tabs = vim.api.nvim_list_tabpages()
      if #tabs <= 1 then return end

      local choices = {}
      for i, tabpage in ipairs(tabs) do
        local current = vim.api.nvim_get_current_tabpage() == tabpage
        local marker = current and ' ' or ' '

        -- Get tab name using our custom function
        local tab_obj = {
          id = tabpage,
          number = function() return i end,
          current_win = function()
            local ok, win_id = pcall(vim.api.nvim_tabpage_get_win, tabpage)
            if not ok then return nil end
            return {
              buf = function()
                local buf_id = vim.api.nvim_win_get_buf(win_id)
                return {
                  name = function() return vim.api.nvim_buf_get_name(buf_id) end,
                  type = function() return vim.bo[buf_id].buftype end,
                }
              end,
            }
          end,
        }

        local name = get_custom_tab_name(tab_obj)
        table.insert(choices, marker .. ' ' .. tostring(i) .. ': ' .. name)
      end

      vim.ui.select(choices, {
        prompt = ' Select tab:',
        format_item = function(item) return item end,
      }, function(choice, idx)
        if choice and idx then vim.api.nvim_set_current_tabpage(tabs[idx]) end
      end)
    end, {
      desc = 'Tab Selector',
    })

    -- Quick tab switching with numbers
    for i = 1, 9 do
      keymap('n', '<leader>' .. i, function()
        local tabs = vim.api.nvim_list_tabpages()
        if tabs[i] then vim.api.nvim_set_current_tabpage(tabs[i]) end
      end, {
        desc = 'Go to tab ' .. i,
      })
    end

    -- Tab management keybindings
    keymap('n', '<leader>tn', '<cmd>tabnew<cr>', {
      desc = 'New tab',
    })
    keymap('n', '<leader>tc', '<cmd>tabclose<cr>', {
      desc = 'Close tab',
    })
    keymap('n', '<leader>to', '<cmd>tabonly<cr>', {
      desc = 'Close all other tabs',
    })
    keymap('n', '<leader>t]', '<cmd>tabnext<cr>', {
      desc = 'Next tab',
    })
    keymap('n', '<leader>t[', '<cmd>tabprevious<cr>', {
      desc = 'Previous tab',
    })
    keymap('n', '<leader>tm]', '<cmd>+tabmove<cr>', {
      desc = 'Move tab right',
    })
    keymap('n', '<leader>tm[', '<cmd>-tabmove<cr>', {
      desc = 'Move tab left',
    })

    -- Tab rename functionality
    keymap('n', '<leader>tR', function()
      local current_tab = vim.api.nvim_get_current_tabpage()
      local current_name = vim.fn.gettabvar(current_tab, 'tabby_name', '')

      vim.ui.input({
        prompt = 'Tab name: ',
        default = current_name,
      }, function(name)
        if name and name ~= '' then
          vim.api.nvim_tabpage_set_var(current_tab, 'tabby_name', name)
          -- Force tabline refresh
          vim.cmd('redrawtabline')
        end
      end)
    end, {
      desc = 'Rename current tab',
    })

    -- Jump to tab mode (similar to barbar.nvim)
    keymap('n', '<leader>tj', '<cmd>Tabby jump_to_tab<cr>', {
      desc = 'Jump to tab',
    })
    keymap('n', '<leader>tw', '<cmd>Tabby pick_window<cr>', {
      desc = 'Pick window',
    })
  end,
}
