-- Completion setup with nvim-cmp
return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline', -- For command line completion
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'onsails/lspkind.nvim', -- For better icons
    'rafamadriz/friendly-snippets', -- Collection of snippets
    'Exafunction/codeium.nvim', -- AI completion
  },
  event = 'InsertEnter',
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local lspkind = require('lspkind')

    cmp.setup({
      -- Enable snippet support
      snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
      },

      mapping = cmp.mapping.preset.insert({
        -- Arrow key navigation (as requested)
        ['<Up>'] = cmp.mapping.select_prev_item({
          behavior = cmp.SelectBehavior.Select,
        }),
        ['<Down>'] = cmp.mapping.select_next_item({
          behavior = cmp.SelectBehavior.Select,
        }),

        -- Keep Ctrl navigation as alternative
        ['<C-k>'] = cmp.mapping.select_prev_item({
          behavior = cmp.SelectBehavior.Select,
        }),
        ['<C-j>'] = cmp.mapping.select_next_item({
          behavior = cmp.SelectBehavior.Select,
        }),

        ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),

        -- Ctrl+L for snippet expansion (Tab is reserved for Codeium)
        ['<C-l>'] = cmp.mapping(function(fallback)
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),

        -- Shift+K for snippet jumping backward only
        ['<S-k>'] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),

        -- Toggle completion menu with Ctrl+Space
        ['<C-Space>'] = cmp.mapping(function()
          if cmp.visible() then
            cmp.abort()
          else
            cmp.complete()
          end
        end),

        ['<C-e>'] = cmp.mapping.abort(), -- Close completion window

        -- ONLY Enter confirms completion
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false, -- Don't auto-select first item
        }),
      }),

      -- Enhanced appearance configuration with documentation
      window = {
        completion = cmp.config.window.bordered({
          border = 'rounded',
          winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
        }),
        documentation = cmp.config.window.bordered({
          border = 'rounded',
          max_height = 15,
          max_width = 60,
        }),
      },

      -- Enhanced formatting with icons and better layout
      formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          maxwidth = 50,
          ellipsis_char = '...',
          before = function(entry, vim_item)
            -- Enhanced source names with better styling
            local source_names = {
              nvim_lsp = '󰒋 LSP',
              luasnip = '󰆐 Snippet',
              buffer = '󰈔 Buffer',
              path = '󰉋 Path',
              npm = '󰎙 NPM',
              ['css-modules'] = '󰌜 CSS',
              emoji = '󰞅 Emoji',
              dictionary = '󰗊 Dict',
            }
            vim_item.menu = source_names[entry.source.name] or '[' .. entry.source.name .. ']'

            -- Truncate long completions
            if string.len(vim_item.abbr) > 30 then vim_item.abbr = string.sub(vim_item.abbr, 1, 27) .. '...' end

            return vim_item
          end,
        }),
      },

      -- Performance and behavior settings
      performance = {
        debounce = 60,
        throttle = 30,
        fetching_timeout = 500,
      },

      -- Completion behavior
      completion = {
        keyword_length = 1,
        completeopt = 'menu,menuone,noinsert,noselect',
      },

      -- View configuration to ensure documentation shows
      view = {
        entries = {
          name = 'custom',
          selection_order = 'near_cursor',
        },
        docs = {
          auto_open = true,
        },
      },

      -- DISABLED: Experimental ghost text to avoid conflicts with Codeium
      -- experimental = {
      --     ghost_text = {
      --         hl_group = 'CmpGhostText'
      --     }
      -- },

      sources = cmp.config.sources({
        {
          name = 'nvim_lsp',
          priority = 1000,
        },
        {
          name = 'luasnip',
          priority = 750,
        },
        {
          name = 'buffer',
          priority = 500,
          keyword_length = 3,
        },
        {
          name = 'path',
          priority = 250,
        },
      }, {
        {
          name = 'npm',
          keyword_length = 4,
        },
        {
          name = 'css-modules',
        },
        {
          name = 'emoji',
          keyword_length = 2,
        },
        {
          name = 'dictionary',
          keyword_length = 2,
        },
      }),
    })

    -- Enhanced filetype-specific configurations
    cmp.setup.filetype('json', {
      sources = cmp.config.sources(
        { {
          name = 'nvim_lsp',
        }, {
          name = 'npm',
        } },
        { {
          name = 'buffer',
          keyword_length = 3,
        }, {
          name = 'path',
        } }
      ),
    })

    cmp.setup.filetype(
      { 'javascript', 'typescript', 'typescriptreact', 'javascriptreact', 'html', 'css', 'scss', 'less' },
      {
        sources = cmp.config.sources({
          {
            name = 'nvim_lsp',
          },
          {
            name = 'luasnip',
          },
          {
            name = 'css-modules',
          },
        }, {
          {
            name = 'buffer',
            keyword_length = 3,
          },
          {
            name = 'path',
          },
        }),
      }
    )

    cmp.setup.filetype('markdown', {
      sources = cmp.config.sources({
        {
          name = 'luasnip',
        },
        {
          name = 'emoji',
          keyword_length = 2,
        },
        {
          name = 'dictionary',
          keyword_length = 2,
        },
      }, { {
        name = 'buffer',
        keyword_length = 3,
      } }),
    })

    -- Git commit messages
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        {
          name = 'buffer',
          keyword_length = 3,
        },
        {
          name = 'emoji',
          keyword_length = 2,
        },
      }),
    })

    -- Command line completion
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { {
        name = 'buffer',
      } },
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ {
        name = 'path',
      } }, { {
        name = 'cmdline',
      } }),
    })

    -- Custom highlight groups for better appearance
    vim.api.nvim_set_hl(0, 'CmpPmenu', {
      bg = '#1e1e2e',
    })
    vim.api.nvim_set_hl(0, 'CmpSel', {
      bg = '#45475a',
      bold = true,
    })

    -- Setup snippets after everything is loaded
    vim.schedule(function() require('config.snippets').setup() end)

    -- Backup: Ensure snippets are loaded when opening Java files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = function() require('config.snippets').setup() end,
      desc = 'Load Java snippets',
    })
  end,
}
