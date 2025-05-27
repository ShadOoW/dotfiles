-- Completion setup with nvim-cmp
return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
  },
  event = 'InsertEnter',
  config = function()
    local cmp = require('cmp')
    cmp.setup({
      mapping = cmp.mapping.preset.insert(),
      sources = cmp.config.sources({
        {
          name = 'nvim_lsp',
        },
        {
          name = 'buffer',
        },
        {
          name = 'path',
        },
        {
          name = 'npm',
          keyword_length = 4,
        },
        {
          name = 'css-modules',
        },
        {
          name = 'emoji',
        },
        {
          name = 'dictionary',
        }, -- Uncomment if you have copilot or other AI source installed
        -- { name = "copilot" },
      }),
    })

    -- Filetype-specific sources
    cmp.setup.filetype('json', {
      sources = cmp.config.sources({
        {
          name = 'npm',
        },
        {
          name = 'buffer',
        },
        {
          name = 'path',
        },
      }),
    })

    cmp.setup.filetype({
      'javascript',
      'typescript',
      'typescriptreact',
      'javascriptreact',
      'html',
      'css',
    }, {
      sources = cmp.config.sources({
        {
          name = 'nvim_lsp',
        },
        {
          name = 'css-modules',
        },
        {
          name = 'buffer',
        },
        {
          name = 'path',
        },
      }),
    })

    cmp.setup.filetype('markdown', {
      sources = cmp.config.sources({
        {
          name = 'emoji',
        },
        {
          name = 'dictionary',
        },
        {
          name = 'buffer',
        },
      }),
    })

    -- AI/code suggestion sources can be added globally or per filetype as needed
  end,
}
