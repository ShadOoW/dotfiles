-- Modern Noice configuration for compact notifications
-- Compact 1-line notifications with level icons
return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = { 'MunifTanjim/nui.nvim', 'nvim-treesitter/nvim-treesitter' },
  config = function()
    -- Override vim.notify before setting up noice
    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
      opts = opts or {}
      if type(msg) == 'table' then msg = table.concat(msg, ' ') end
      msg = tostring(msg or '')

      local icons = {
        [vim.log.levels.ERROR] = '',
        [vim.log.levels.WARN] = '',
        [vim.log.levels.INFO] = '',
        [vim.log.levels.DEBUG] = '',
        [vim.log.levels.TRACE] = '',
      }

      level = level or vim.log.levels.INFO
      local icon = icons[level] or ''

      -- Format message as: icon | message
      local clean_msg = msg:gsub('%s*\n%s*', ' '):gsub('%s+', ' '):gsub('^%s*(.-)%s*$', '%1')
      local formatted_msg = string.format('%s | %s', icon, clean_msg)

      return original_notify(formatted_msg, level, opts)
    end

    require('noice').setup({
      -- Disable commands to prevent unwanted panels
      commands = {
        enabled = false,
      },

      -- LSP integration
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
        progress = {
          enabled = true,
          format = 'lsp_progress',
          format_done = 'lsp_progress_done',
          throttle = 1000 / 30,
          view = 'mini',
        },
        hover = {
          enabled = true,
          silent = true,
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true,
            luasnip = true,
            throttle = 50,
          },
        },
        message = {
          enabled = true,
          view = 'notify',
        },
        documentation = {
          view = 'hover',
          opts = {
            lang = 'markdown',
            replace = true,
            render = 'plain',
            format = { '{message}' },
            win_options = {
              concealcursor = 'n',
              conceallevel = 3,
            },
          },
        },
      },

      -- Modern presets for better UX
      presets = {
        bottom_search = false,
        command_palette = false,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },

      -- Views configuration
      views = {
        -- Compact notification view
        notify = {
          backend = 'notify',
          fallback = 'mini',
          format = 'notify',
          replace = false,
          merge = false,
        },

        -- Command line popup
        cmdline_popup = {
          position = {
            row = '50%',
            col = '50%',
          },
          size = {
            width = 60,
            height = 'auto',
          },
          border = {
            style = 'single',
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = {
              Normal = 'NoiceCmdlinePopup',
              FloatBorder = 'NoiceCmdlinePopupBorder',
              CursorLine = 'PmenuSel',
              Search = 'None',
            },
          },
        },

        -- Mini view for progress messages
        mini = {
          backend = 'mini',
          relative = 'editor',
          align = 'message-right',
          timeout = 3000,
          reverse = true,
          focusable = false,
          position = {
            row = -2,
            col = '100%',
          },
          size = 'auto',
          border = {
            style = 'none',
          },
          win_options = {
            winblend = 0,
            winhighlight = {
              Normal = 'NoiceMini',
              IncSearch = '',
              CurSearch = '',
              Search = '',
            },
          },
        },

        -- Split view for long messages
        split = {
          enter = true,
          relative = 'editor',
          position = 'bottom',
          size = '20%',
          close = {
            keys = { 'q', '<Esc>' },
          },
          win_options = {
            winhighlight = {
              Normal = 'Normal',
              FloatBorder = 'FloatBorder',
            },
          },
        },
      },

      -- Smart message routing
      routes = { -- Filter out noisy LSP messages
        {
          filter = {
            event = 'lsp',
            kind = 'progress',
            cond = function(message)
              local client = vim.tbl_get(message.opts, 'progress', 'client')
              return client == 'lua_ls'
            end,
          },
          opts = {
            skip = true,
          },
        }, -- Skip file write notifications
        {
          filter = {
            event = 'msg_show',
            kind = '',
            find = 'written',
          },
          opts = {
            skip = true,
          },
        }, -- Skip search wrap messages
        {
          filter = {
            event = 'msg_show',
            kind = 'search_count',
          },
          opts = {
            skip = true,
          },
        }, -- Route short informational messages to mini view
        {
          filter = {
            event = 'msg_show',
            any = {
              {
                find = '%d+L, %d+B',
              },
              {
                find = '; after #%d+',
              },
              {
                find = '; before #%d+',
              },
              {
                find = '%d fewer lines',
              },
              {
                find = '%d more lines',
              },
            },
          },
          view = 'mini',
        }, -- Important confirmations stay in cmdline
        {
          filter = {
            event = 'msg_show',
            any = {
              {
                find = '%[Y/n%]',
              },
              {
                find = '%[y/N%]',
              },
              {
                find = '%[Y/N/C%]',
              },
              {
                find = 'Save changes',
              },
              {
                find = 'Overwrite existing file',
              },
              {
                find = 'No write since last change',
              },
            },
          },
          view = 'cmdline',
        }, -- Route errors and warnings to notifications
        {
          filter = {
            event = 'msg_show',
            any = {
              {
                error = true,
              },
              {
                warning = true,
              },
              {
                min_height = 2,
              },
            },
          },
          view = 'notify',
        }, -- Route long messages to split
        {
          filter = {
            event = 'msg_show',
            min_height = 10,
            cond = function() return vim.fn.getcmdwintype() == '' end,
          },
          view = 'split',
        },
      },

      -- Built-in notification backend settings
      notify = {
        enabled = true,
        view = 'notify',
      },

      -- Message settings
      messages = {
        enabled = true,
        view = 'notify',
        view_error = 'notify',
        view_warn = 'notify',
        view_history = 'messages',
        view_search = 'virtualtext',
      },

      -- Command line settings with nerd font icons
      cmdline = {
        enabled = true,
        view = 'cmdline_popup',
        opts = {},
        format = {
          cmdline = {
            pattern = '^:',
            icon = '󰘳',
            lang = 'vim',
          },
          search_down = {
            kind = 'search',
            pattern = '^/',
            icon = '󱦞',
            lang = 'regex',
          },
          search_up = {
            kind = 'search',
            pattern = '^%?',
            icon = '󱦞',
            lang = 'regex',
          },
          filter = {
            pattern = '^:%s*!',
            icon = '',
            lang = 'bash',
          },
          lua = {
            pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' },
            icon = '󰢱',
            lang = 'lua',
          },
          help = {
            pattern = '^:%s*he?l?p?%s+',
            icon = '󰮥',
          },
          input = {
            view = 'cmdline_input',
            icon = '󰭙',
          },
        },
      },

      -- Popup menu settings
      popupmenu = {
        enabled = true,
        backend = 'nui',
        kind_icons = {},
      },

      -- Remove level labels globally
      format = {
        level = false, -- Don't show level text
      },

      -- Health check settings
      health = {
        checker = false,
      },
    })

    -- Set up Tokyo Night inspired colors for Noice
    vim.api.nvim_set_hl(0, 'NoiceConfirm', {
      bg = '#414868',
      fg = '#c0caf5',
    })
    vim.api.nvim_set_hl(0, 'NoiceConfirmBorder', {
      fg = '#7aa2f7',
    })
    vim.api.nvim_set_hl(0, 'NoiceCmdline', {
      bg = '#24283b',
      fg = '#c0caf5',
    })
    vim.api.nvim_set_hl(0, 'NoiceCmdlineIcon', {
      fg = '#7aa2f7',
    })
    vim.api.nvim_set_hl(0, 'NoiceCmdlinePopup', {
      bg = '#1a1b26',
    })
    vim.api.nvim_set_hl(0, 'NoiceCmdlinePopupBorder', {
      fg = '#565f89',
    })
    vim.api.nvim_set_hl(0, 'NoiceCompletionItemKindDefault', {
      fg = '#9ece6a',
    })
    vim.api.nvim_set_hl(0, 'NoiceMini', {
      bg = '#1a1b26',
      fg = '#c0caf5',
    })

    -- Custom keymaps for better UX
    vim.keymap.set('n', '<leader>nn', '<cmd>Noice<cr>', {
      desc = 'Noice Messages',
    })
    vim.keymap.set('n', '<leader>nh', '<cmd>Noice history<cr>', {
      desc = 'Noice History',
    })
    vim.keymap.set('n', '<leader>nd', '<cmd>Noice dismiss<cr>', {
      desc = 'Dismiss Noice Messages',
    })
    vim.keymap.set('n', '<leader>ne', '<cmd>Noice errors<cr>', {
      desc = 'Noice Errors',
    })
  end,

  -- Keybindings for enhanced scroll control
  keys = {
    {
      '<S-Enter>',
      function()
        local cmdline = vim.fn.getcmdline()
        if cmdline and cmdline ~= '' then require('noice').redirect(cmdline) end
      end,
      mode = 'c',
      desc = 'Redirect command to split',
    },
    {
      '<c-f>',
      function()
        if not require('noice.lsp').scroll(4) then return '<c-f>' end
      end,
      silent = true,
      expr = true,
      desc = 'Scroll forward',
      mode = { 'i', 'n', 's' },
    },
    {
      '<c-b>',
      function()
        if not require('noice.lsp').scroll(-4) then return '<c-b>' end
      end,
      silent = true,
      expr = true,
      desc = 'Scroll backward',
      mode = { 'i', 'n', 's' },
    },
  },
}
