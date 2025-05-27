return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    -- Add any missing commands
    commands = {
      history = {
        -- options for the message history that you get with `:Noice`
        view = 'split',
        opts = {
          enter = true,
          format = 'details',
        },
        filter = {
          any = {
            {
              event = 'notify',
            },
            {
              error = true,
            },
            {
              warning = true,
            },
            {
              event = 'msg_show',
              kind = {
                '',
              },
            },
            {
              event = 'lsp',
              kind = 'message',
            },
          },
        },
      },
    },
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
      -- LSP message handling configuration
      progress = {
        enabled = true,
        format = 'lsp_progress',
        format_done = 'lsp_progress_done',
        throttle = 1000 / 30, -- frequency to update lsp progress message
        view = 'mini',
      },
      hover = {
        enabled = true,
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
        },
      },
      message = {
        enabled = true,
      },
      documentation = {
        enabled = true,
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = true, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    views = {
      cmdline_popup = {
        position = {
          row = '50%',
          col = '50%',
        },
        size = {
          width = 60,
          height = 'auto',
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
          padding = {
            0,
            1,
          },
        },
        win_options = {
          winhighlight = {
            Normal = 'Normal',
            FloatBorder = 'DiagnosticInfo',
          },
        },
      },
    },
    routes = {
      {
        filter = {
          event = 'msg_show',
          kind = '',
          find = 'written',
        },
        opts = {
          skip = true,
        },
      },
    },
  },
  keys = {
    {
      '<S-Enter>',
      function() require('noice').redirect(vim.fn.getcmdline()) end,
      mode = 'c',
      desc = 'Redirect Cmdline',
    },
    {
      '<leader>nl',
      function() require('noice').cmd('last') end,
      desc = 'Noice Last Message',
    },
    {
      '<leader>nh',
      function() require('noice').cmd('history') end,
      desc = 'Noice History',
    },
    {
      '<leader>na',
      function() require('noice').cmd('all') end,
      desc = 'Noice All',
    },
    {
      '<leader>nd',
      function() require('noice').cmd('dismiss') end,
      desc = 'Dismiss All',
    },
    {
      '<c-f>',
      function()
        if not require('noice.lsp').scroll(4) then return '<c-f>' end
      end,
      silent = true,
      expr = true,
      desc = 'Scroll forward',
      mode = {
        'i',
        'n',
        's',
      },
    },
    {
      '<c-b>',
      function()
        if not require('noice.lsp').scroll(-4) then return '<c-b>' end
      end,
      silent = true,
      expr = true,
      desc = 'Scroll backward',
      mode = {
        'i',
        'n',
        's',
      },
    },
  },
}
