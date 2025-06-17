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

        -- Toggle completion menu with Ctrl+Space (LSP first, then buffer fallback)
        ['<C-Space>'] = cmp.mapping(function()
          if cmp.visible() then
            cmp.abort()
          else
            -- First try LSP only with snippet filtering
            cmp.complete({
              config = {
                sources = {
                  {
                    name = 'nvim_lsp',
                    priority = 1000,
                    option = {
                      -- Exclude snippets from LSP completions
                      snippet_support = false,
                    },
                    entry_filter = function(entry, ctx)
                      local kind = entry:get_kind()
                      local cmp = require('cmp')

                      -- Filter out snippet-type completions
                      if kind == cmp.lsp.CompletionItemKind.Snippet then return false end

                      local completion_item = entry:get_completion_item()

                      -- Filter out completions ending with ~ (snippet indicator)
                      local label = completion_item.label or ''
                      if label:match('~$') then return false end

                      -- Filter out snippet-like characteristics
                      if completion_item.insertTextFormat == 2 then return false end

                      -- Filter out snippet syntax
                      if completion_item.insertText and completion_item.insertText:match('%$%d') then return false end

                      return true
                    end,
                  },
                },
              },
            })

            -- If no LSP completions available, fallback to buffer after a short delay
            vim.defer_fn(function()
              if not cmp.visible() or #cmp.get_entries() == 0 then
                cmp.complete({
                  config = {
                    sources = {
                      {
                        name = 'buffer',
                        priority = 500,
                        keyword_length = 2,
                        option = {
                          get_bufnrs = function() return vim.api.nvim_list_bufs() end,
                        },
                      },
                    },
                  },
                })
              end
            end, 100)
          end
        end),

        -- Toggle snippet completion with Shift+Ctrl+Space
        ['<C-S-Space>'] = cmp.mapping(function()
          if cmp.visible() then
            cmp.abort()
          else
            -- Show snippets and all completions
            cmp.complete({
              config = {
                sources = {
                  {
                    name = 'luasnip',
                    priority = 1000,
                  },
                  {
                    name = 'nvim_lsp',
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
                },
              },
            })
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
        completion = {
          border = 'none',
          winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
          scrollbar = false,
        },
        documentation = {
          border = 'none',
          max_height = 15,
          max_width = 60,
          winhighlight = 'Normal:CmpPmenu,Search:None',
          scrollbar = false,
        },
      },

      -- Minimalist formatting - only show completion text
      formatting = {
        fields = { 'abbr' }, -- Only show the completion text
        format = function(entry, vim_item)
          -- Remove all visual clutter - just the completion text
          vim_item.menu = nil -- No source indicators
          vim_item.kind = nil -- No icons

          -- Keep completion text clean and simple
          if string.len(vim_item.abbr) > 40 then vim_item.abbr = string.sub(vim_item.abbr, 1, 37) .. '...' end

          return vim_item
        end,
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
          max_item_count = 50, -- Limit for better performance
          -- Ensure LSP completions don't include snippets
          entry_filter = function(entry, ctx)
            local kind = entry:get_kind()
            local cmp = require('cmp')

            -- Filter out snippet-type completions from LSP
            if kind == cmp.lsp.CompletionItemKind.Snippet then return false end

            local completion_item = entry:get_completion_item()

            -- Filter out completions ending with ~ (common snippet indicator)
            local label = completion_item.label or ''
            if label:match('~$') then return false end

            return true
          end,
        },
        {
          name = 'buffer',
          priority = 300, -- Reduced priority
          keyword_length = 4, -- Higher threshold to reduce noise
          max_item_count = 10, -- Limit buffer suggestions
        },
        {
          name = 'path',
          priority = 200, -- Reduced priority
          keyword_length = 3, -- Higher threshold
          max_item_count = 5, -- Limit path suggestions
        },
      }, { -- Secondary group - snippets and other completions
        {
          name = 'luasnip',
          priority = 150, -- Lower priority for snippets in default completion
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
      sources = cmp.config.sources({
        {
          name = 'nvim_lsp',
          entry_filter = function(entry, ctx)
            local kind = entry:get_kind()
            local cmp = require('cmp')

            -- Filter out snippet-type completions
            if kind == cmp.lsp.CompletionItemKind.Snippet then return false end

            local completion_item = entry:get_completion_item()

            -- Filter out completions ending with ~ (snippet indicator)
            local label = completion_item.label or ''
            if label:match('~$') then return false end

            return true
          end,
        },
        {
          name = 'npm',
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
    })

    cmp.setup.filetype(
      { 'javascript', 'typescript', 'typescriptreact', 'javascriptreact', 'html', 'css', 'scss', 'less' },
      {
        sources = cmp.config.sources({
          {
            name = 'nvim_lsp',
            entry_filter = function(entry, ctx)
              local kind = entry:get_kind()
              local cmp = require('cmp')

              -- Filter out snippet-type completions
              if kind == cmp.lsp.CompletionItemKind.Snippet then return false end

              local completion_item = entry:get_completion_item()

              -- Filter out completions ending with ~ (snippet indicator)
              local label = completion_item.label or ''
              if label:match('~$') then return false end

              return true
            end,
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

    -- Modern, clean highlight groups with solid background
    vim.api.nvim_set_hl(0, 'CmpPmenu', {
      bg = '#181926', -- Solid dark background, no transparency
      fg = '#c0caf5',
      blend = 0, -- Ensure no transparency
    })
    vim.api.nvim_set_hl(0, 'CmpSel', {
      bg = '#2e3350', -- Solid selection highlight
      fg = '#c0caf5',
      bold = false, -- Less aggressive highlighting
      blend = 0, -- Ensure no transparency
    })

    -- Enhanced highlight groups for completion styling
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMethod', {
      fg = '#7aa2f7', -- Tokyo Night blue for method names
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrFunction', {
      fg = '#7aa2f7', -- Tokyo Night blue for function names
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrConstructor', {
      fg = '#bb9af7', -- Tokyo Night purple for constructors
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrField', {
      fg = '#9ece6a', -- Tokyo Night green for fields
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrProperty', {
      fg = '#9ece6a', -- Tokyo Night green for properties
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrVariable', {
      fg = '#f7768e', -- Tokyo Night red for variables
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrConstant', {
      fg = '#ff9e64', -- Tokyo Night orange for constants
    })
    vim.api.nvim_set_hl(0, 'CmpItemMenuParams', {
      fg = '#565f89', -- Grayed out for parameters
      italic = false, -- Clean, not italic
    })
    vim.api.nvim_set_hl(0, 'CmpItemMenuType', {
      fg = '#7dcfff', -- Tokyo Night cyan for return types
      italic = false, -- Clean, not italic
    })
    vim.api.nvim_set_hl(0, 'CmpItemMenu', {
      fg = '#565f89', -- Consistent menu color
      italic = false,
    })
    vim.api.nvim_set_hl(0, 'CmpPmenuBorder', {
      fg = '#363a4f', -- Subtle border color
    })

    -- Additional highlight groups for parameter styling
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMethodParams', {
      fg = '#565f89', -- Grayed out parameters for methods
      italic = true,
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrFunctionParams', {
      fg = '#565f89', -- Grayed out parameters for functions
      italic = true,
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrConstructorParams', {
      fg = '#565f89', -- Grayed out parameters for constructors
      italic = true,
    })

    -- Additional UI improvements
    vim.api.nvim_set_hl(0, 'CmpItemKind', {
      fg = '#7aa2f7', -- Tokyo Night blue for kind icons
      bg = 'NONE',
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbr', {
      fg = '#c0caf5', -- Main text color
      bg = 'NONE',
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', {
      fg = '#bb9af7', -- Purple for matched characters
      bg = 'NONE',
      bold = true,
    })
    vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', {
      fg = '#bb9af7', -- Purple for fuzzy matched characters
      bg = 'NONE',
      bold = true,
    })

    -- Dedicated color for parameters
    vim.api.nvim_set_hl(0, 'CmpItemAbbrParams', {
      fg = '#7dcfff', -- Distinct cyan for parameters
      italic = true,
    })

    -- Auto-command to re-apply highlights after colorscheme changes
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
        vim.api.nvim_set_hl(0, 'CmpItemAbbrMethodName', {
          fg = '#7aa2f7',
          bold = true,
        })
        vim.api.nvim_set_hl(0, 'CmpItemAbbrFunctionName', {
          fg = '#7aa2f7',
          bold = true,
        })
        vim.api.nvim_set_hl(0, 'CmpItemAbbrConstructorName', {
          fg = '#bb9af7',
          bold = true,
        })
        -- Re-apply parameter highlight after colorscheme changes
        vim.api.nvim_set_hl(0, 'CmpItemAbbrParams', {
          fg = '#7dcfff',
          italic = true,
        })
      end,
    })

    -- Setup snippets after everything is loaded
    vim.schedule(function() require('config.snippets').setup() end)

    -- Custom function to apply parameter highlighting
    local function setup_parameter_highlighting()
      -- Create an autocmd to apply custom highlighting after completion menu is shown
      vim.api.nvim_create_autocmd('CompleteChanged', {
        callback = function()
          -- This will be triggered when completion menu changes
          -- We can use this to apply custom highlighting to parameters
          vim.schedule(function()
            local pumenu = vim.fn.pumvisible()
            if pumenu == 1 then
              -- Apply custom highlighting logic here if needed
              -- For now, we rely on the abbr_hl_group approach
            end
          end)
        end,
      })
    end

    setup_parameter_highlighting()
  end,
}
