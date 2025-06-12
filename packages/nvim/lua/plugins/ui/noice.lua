return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify', 'nvim-treesitter/nvim-treesitter' },
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
              kind = { '' },
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
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = {
            Normal = 'Normal',
            FloatBorder = 'DiagnosticInfo',
          },
        },
      },
      confirm = {
        position = {
          row = '50%',
          col = '50%',
        },
        size = {
          width = 'auto',
          height = 'auto',
        },
        border = {
          style = 'rounded',
          padding = { 1, 2 },
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
      {
        -- Skip confirmation dialogs entirely - let vim handle them
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
              find = '%[y/n/c%]',
            },
            {
              find = 'Save changes',
            },
            {
              find = 'No write since last change',
            },
            {
              kind = 'confirm',
            },
          },
        },
        view = 'confirm',
      },
      {
        -- Route command output to split view instead of notifications
        filter = {
          event = 'msg_show',
          min_height = 3,
        },
        view = 'notify',
      },
      {
        -- Route long messages but exclude interactive prompts
        filter = {
          event = 'msg_show',
          find = '.+',
          -- Exclude confirmation dialogs, prompts, and interactive messages
          ['not'] = {
            any = {
              {
                find = '%[Y/n%]',
              }, -- Yes/No prompts
              {
                find = '%[y/N%]',
              }, -- yes/No prompts
              {
                find = '%[Y/N/C%]',
              }, -- Yes/No/Cancel prompts
              {
                find = '%[y/n/c%]',
              }, -- yes/no/cancel prompts
              {
                find = 'Press ENTER',
              }, -- Press ENTER prompts
              {
                find = 'More %(%d+%%%)',
              }, -- More paging prompts
              {
                find = '^E%d+:',
              }, -- Error messages that need visibility
              {
                find = 'really want to',
              }, -- Common confirmation text
              {
                find = 'Are you sure',
              }, -- Common confirmation text
              {
                find = 'Confirm',
              }, -- Confirmation dialogs
              {
                find = '^--',
              }, -- Command output that should stay visible
              {
                kind = 'confirm',
              }, -- Explicit confirm kind
              {
                kind = 'return_prompt',
              }, -- Return prompts
            },
          },
        },
        view = 'notify',
        opts = {
          replace = false,
          merge = false,
        },
      },
    },
  },
  keys = {
    {
      '<S-Enter>',
      function()
        local cmdline = vim.fn.getcmdline()
        if cmdline and cmdline ~= '' then require('noice').redirect(cmdline) end
      end,
      mode = 'c',
      desc = 'Redirect command output to split view',
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
