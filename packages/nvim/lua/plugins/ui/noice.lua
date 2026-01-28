-- Enhanced notification and message system using noice.nvim
-- Provides minimal distraction with intelligent routing and filtering
return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
  opts = {
    -- LSP integration for enhanced hover, signature, and progress
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
      hover = {
        enabled = true,
        silent = false,
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true,
          throttle = 50,
        },
      },
      progress = {
        enabled = true,
        format = 'lsp_progress',
        format_done = 'lsp_progress_done',
        throttle = 1000 / 30, -- frequency to update lsp progress message
        view = 'mini',
      },
      message = {
        enabled = true,
        view = 'notify',
        opts = {},
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
    -- Presets for common use cases
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    -- Message routing configuration
    routes = { -- Route short informational messages to mini view
      {
        filter = {
          event = 'msg_show',
          kind = '',
          max_length = 60,
        },
        view = 'mini',
      }, -- Route errors and warnings to notify
      {
        filter = {
          event = 'msg_show',
          kind = { 'error', 'warning' },
        },
        view = 'notify',
      }, -- Route confirmations to popup dialog
      {
        filter = {
          event = 'msg_show',
          kind = 'confirm',
        },
        view = 'popup',
      }, -- Route long messages to split view
      {
        filter = {
          event = 'msg_show',
          min_length = 100,
        },
        view = 'split',
      }, -- Route cmdline messages appropriately
      {
        filter = {
          event = 'cmdline',
          kind = ':',
        },
        view = 'cmdline',
      },
    },
    -- Command line configuration
    cmdline = {
      enabled = true,
      view = 'cmdline',
      opts = {},
      format = {
        cmdline = {
          pattern = '^:',
          icon = '',
          lang = 'vim',
        },
        search_down = {
          kind = 'search',
          pattern = '^/',
          icon = '󱈆',
          lang = 'regex',
        },
        search_up = {
          kind = 'search',
          pattern = '^%?',
          icon = '󱈆',
          lang = 'regex',
        },
        filter = {
          pattern = '^:%s*!',
          icon = '󰈲',
          lang = 'bash',
        },
        lua = {
          pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' },
          icon = '',
          lang = 'lua',
        },
        help = {
          pattern = '^:%s*he?l?p?%s+',
          icon = '󰋗',
        },
        input = {},
      },
    },
    -- Messages configuration
    messages = {
      enabled = true,
      view = 'notify',
      view_error = 'notify',
      view_warn = 'notify',
      view_history = 'messages',
      view_search = 'virtualtext',
    },
    -- Popup menu configuration
    popupmenu = {
      enabled = true,
      backend = 'nui',
      kind_icons = {},
    },
    -- Notification configuration
    notify = {
      enabled = true,
      view = 'notify',
    },
    -- View configurations
    views = {
      cmdline_popup = {
        position = {
          row = 5,
          col = '50%',
        },
        size = {
          width = 60,
          height = 'auto',
        },
        border = {
          style = 'rounded',
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = 'Normal:Normal,FloatBorder:DiagnosticInfo',
        },
      },
      popupmenu = {
        relative = 'editor',
        position = {
          row = 8,
          col = '50%',
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = 'rounded',
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = 'Normal:Normal,FloatBorder:DiagnosticInfo',
        },
      },
      hover = {
        border = {
          style = 'rounded',
        },
        position = {
          row = 2,
          col = 2,
        },
        win_options = {
          winhighlight = 'Normal:Normal,FloatBorder:DiagnosticInfo',
        },
      },
      popup = {
        border = {
          style = 'rounded',
        },
        position = '50%',
        size = {
          width = 60,
          height = 20,
        },
        win_options = {
          winhighlight = 'Normal:Normal,FloatBorder:DiagnosticInfo',
        },
      },
      split = {
        enter = true,
        size = '33%',
        win_options = {
          winhighlight = 'Normal:Normal',
        },
      },
      mini = {
        position = {
          row = -2,
          col = '100%',
        },
        size = {
          width = 'auto',
          height = 'auto',
        },
        border = {
          style = 'none',
        },
        win_options = {
          winhighlight = 'Normal:NoiceMini',
        },
      },
    },
    -- Custom format for messages
    format = {
      level = {
        icons = {
          error = ' ',
          warn = ' ',
          info = ' ',
          debug = ' ',
          trace = ' ',
        },
      },
      lsp_progress = { '{progress} {data.progress.message}' },
      lsp_progress_done = { '✓ {data.progress.title}' },
    },
    -- Health check configuration
    health = {
      checker = false,
    },
  },
  config = function(_, opts)
    require('noice').setup(opts)

    -- Setup custom highlight groups with Tokyo Night colors
    local function setup_highlights()
      vim.api.nvim_set_hl(0, 'NoiceFormatProgressDone', {
        fg = '#a6e3a1',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NoiceFormatProgressTodo', {
        fg = '#f9e2af',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NoiceLspProgressClient', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NoiceLspProgressTitle', {
        fg = '#cdd6f4',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NoiceLspProgressSpinner', {
        fg = '#f9e2af',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NoiceMini', {
        fg = '#89b4fa',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NoiceCmdlinePopup', {
        fg = '#cdd6f4',
        bg = '#313244',
      })
      vim.api.nvim_set_hl(0, 'NoiceCmdlinePopupBorder', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NoicePopup', {
        fg = '#cdd6f4',
        bg = '#313244',
      })
      vim.api.nvim_set_hl(0, 'NoicePopupBorder', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NoiceSplit', {
        fg = '#cdd6f4',
        bg = '#1e1e2e',
      })
      vim.api.nvim_set_hl(0, 'NoiceSplitBorder', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
    end

    -- Apply highlights immediately and on colorscheme change
    setup_highlights()
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = setup_highlights,
    })

    -- Override vim.notify for better formatting and truncation
    local notify = require('notify')
    local original_notify = vim.notify

    ---@param msg string
    ---@param level number|nil
    ---@param opts table|nil
    vim.notify = function(msg, level, opts)
      opts = opts or {}

      -- Truncate very long messages
      if type(msg) == 'string' and #msg > 500 then msg = msg:sub(1, 497) .. '...' end

      -- Add timestamp for better tracking
      opts.title = opts.title or 'Neovim'

      -- Filter out noisy messages at the notify level
      -- E486 patterns - comprehensive coverage for all "Pattern not found" variations
      local noisy_patterns = {
        'written$',
        'yanked',
        'lines? changed',
        'substitutions? on',
        'recording',
        'search hit',
        'Already at', -- E486 comprehensive patterns (catch all variations)
        'E486:', -- Standard E486 error format
        'E486 ', -- E486 with space
        'E486$', -- E486 at end of line
        '^E486', -- E486 at start of line
        'Pattern not found', -- Direct pattern not found
        'pattern not found', -- Lowercase version
        'PATTERN NOT FOUND', -- Uppercase version
        'search hit BOTTOM', -- Search wrap messages
        'search hit TOP', -- Search wrap messages
        'No previous search pattern', -- No previous pattern
        'No previous substitute pattern', -- No previous substitute
        '^/%w+$', -- Single word search patterns that fail
        '^%?%w+$', -- Single word reverse search patterns that fail
        '^%d+ lines? changed', -- Line change variations
        '^%d+ substitutions? on', -- Substitution variations
        '^%d+ more lines?', -- More lines messages
        '^%d+ fewer lines?', -- Fewer lines messages
        '^search hit', -- Search hit messages
        '^Already at', -- Already at messages
        '^recording @', -- Recording macro messages
        '^recording', -- Recording messages
        '^W%d+:', -- Warning messages we don't want
        '^%s*$', -- Empty messages
      }

      -- Convert message to string and check patterns
      local msg_str = tostring(msg)
      for _, pattern in ipairs(noisy_patterns) do
        if msg_str:match(pattern) then
          return -- Skip noisy messages
        end
      end

      -- Call original notify
      original_notify(msg, level, opts)
    end

    -- Setup noice-specific keybindings
    local keymap = require('utils.keymap')

    -- Noice command and history management
    keymap.n('<leader>nh', function() require('noice').cmd('history') end, 'Notification History')

    keymap.n('<leader>nl', function() require('noice').cmd('last') end, 'Show Last Message')

    keymap.n('<leader>nc', function() require('noice').cmd('dismiss') end, 'Clear Messages')

    -- Noice enable/disable
    keymap.n('<leader>ne', function() require('noice').cmd('enable') end, 'Enable Noice')

    keymap.n('<leader>nD', function() require('noice').cmd('disable') end, 'Disable Noice')

    -- Auto-refresh lualine when notifications change
    local notify_group = vim.api.nvim_create_augroup('NoiceNotifyUpdate', {
      clear = true,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'NotifyBackground',
      group = notify_group,
      callback = function()
        vim.schedule(function() vim.cmd('redrawstatus') end)
      end,
    })
  end,
}
