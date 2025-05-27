return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  opts = {
    format_on_save = true,
    formatters_by_ft = {
      html = {
        'prettier',
      },
      css = {
        'prettier',
      },
      typescript = {
        'prettier',
      },
      typescriptreact = {
        'prettier',
      },
      astro = {
        'prettier',
      },
      javascript = {
        'prettier',
      },
      javascriptreact = {
        'prettier',
      },
      lua = {
        'stylua',
      },
      -- Add rustywind for tailwind class sorting if desired
    },
    formatters = {
      rustywind = {
        command = 'rustywind',
        args = {
          '--stdin',
        },
        stdin = true,
      },
      stylua = {
        prepend_args = {
          '--column-width',
          '0',
          '--collapse-simple-statement',
          'Never',
          '--indent-width',
          '2',
        },
      },
    },
  },
  config = function(_, opts)
    local conform = require('conform')
    conform.setup(opts)
    vim.keymap.set(
      'n',
      '<leader>ff',
      function()
        conform.format({
          async = true,
          lsp_fallback = true,
        })
      end,
      {
        desc = 'Format file',
      }
    )
  end,
}
