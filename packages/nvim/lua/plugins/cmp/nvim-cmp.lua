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

            -- Additional filtering for Java files to be extra sure
            if vim.bo.filetype == 'java' then
              -- Filter out any completion that has snippet-like characteristics
              if completion_item.insertTextFormat == 2 then -- InsertTextFormat.Snippet
                return false
              end
              -- Filter out completions with snippet syntax (contains $1, $2, etc.)
              if completion_item.insertText and completion_item.insertText:match('%$%d') then return false end
            end

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

    -- Enhanced highlight groups for Java completion styling
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

    -- Enhanced Java configuration for IntelliJ IDEA-like completion
    cmp.setup.filetype('java', {
      completion = {
        keyword_length = 1, -- Start completion after 1 character for better member access
        completeopt = 'menu,menuone,noinsert,noselect',
      },
      mapping = cmp.mapping.preset.insert({
        -- Standard mappings
        ['<Up>'] = cmp.mapping.select_prev_item({
          behavior = cmp.SelectBehavior.Select,
        }),
        ['<Down>'] = cmp.mapping.select_next_item({
          behavior = cmp.SelectBehavior.Select,
        }),
        ['<C-k>'] = cmp.mapping.select_prev_item({
          behavior = cmp.SelectBehavior.Select,
        }),
        ['<C-j>'] = cmp.mapping.select_next_item({
          behavior = cmp.SelectBehavior.Select,
        }),
        -- Enhanced documentation scrolling
        ['<C-u>'] = cmp.mapping(function(fallback)
          if cmp.visible_docs() then
            cmp.scroll_docs(-4)
          else
            fallback()
          end
        end, { 'i', 'c' }),
        ['<C-d>'] = cmp.mapping(function(fallback)
          if cmp.visible_docs() then
            cmp.scroll_docs(4)
          else
            fallback()
          end
        end, { 'i', 'c' }),
        -- Page Up/Down for documentation scrolling
        ['<PageUp>'] = cmp.mapping(function(fallback)
          if cmp.visible_docs() then
            cmp.scroll_docs(-10)
          else
            fallback()
          end
        end, { 'i', 'c' }),
        ['<PageDown>'] = cmp.mapping(function(fallback)
          if cmp.visible_docs() then
            cmp.scroll_docs(10)
          else
            fallback()
          end
        end, { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        }),
        -- Special mapping for dot to trigger member completion
        ['.'] = cmp.mapping(function(fallback)
          fallback() -- Insert the dot
          -- Trigger completion after a short delay
          vim.defer_fn(function()
            if cmp.visible() then cmp.abort() end
            cmp.complete()
          end, 100)
        end, { 'i' }),
      }),
      -- Configure sources to prioritize LSP like IntelliJ IDEA
      sources = cmp.config.sources({
        {
          name = 'nvim_lsp',
          priority = 1000,
          max_item_count = 50,
          -- Enhanced entry filter for IntelliJ IDEA-like behavior
          entry_filter = function(entry, ctx)
            local kind = entry:get_kind()
            local cmp = require('cmp')

            -- Filter out snippet-type completions
            if kind == cmp.lsp.CompletionItemKind.Snippet then return false end

            local completion_item = entry:get_completion_item()
            local label = completion_item.label or ''

            -- Filter out completions ending with ~ (snippet indicator)
            if label:match('~$') then return false end

            -- Filter out obvious snippet syntax
            if completion_item.insertText and completion_item.insertText:match('%$%d') then return false end

            -- Get current context for IntelliJ-like filtering
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = line:sub(1, col)

            -- For member access (after dot), prioritize relevant members
            if before_cursor:match('%.%s*$') then
              -- IntelliJ shows methods, fields, constants first for member access
              local relevant_kinds = {
                [cmp.lsp.CompletionItemKind.Method] = true,
                [cmp.lsp.CompletionItemKind.Field] = true,
                [cmp.lsp.CompletionItemKind.Property] = true,
                [cmp.lsp.CompletionItemKind.Constant] = true,
                [cmp.lsp.CompletionItemKind.EnumMember] = true,
                [cmp.lsp.CompletionItemKind.Variable] = true,
              }

              -- Allow relevant kinds, but also allow others with lower priority
              return true -- Let sorting handle the prioritization
            end

            return true
          end,
        },
      }, {
        {
          name = 'buffer',
          priority = 200,
          keyword_length = 4,
          max_item_count = 5,
          option = {
            get_bufnrs = function()
              -- Only search current Java buffer
              local current_buf = vim.api.nvim_get_current_buf()
              if vim.bo[current_buf].filetype == 'java' then return { current_buf } end
              return {}
            end,
          },
        },
        {
          name = 'path',
          priority = 100,
          keyword_length = 3,
          max_item_count = 3,
        },
      }),
      -- IntelliJ IDEA-like sorting: alphabetical with kind priority
      sorting = {
        priority_weight = 2,
        comparators = { -- First, prioritize exact matches
          cmp.config.compare.exact, -- Then, custom comparator for IntelliJ-like member access
          function(entry1, entry2)
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = line:sub(1, col)

            -- For member access, prioritize by kind like IntelliJ
            if before_cursor:match('%.%s*$') then
              local kind1 = entry1:get_kind()
              local kind2 = entry2:get_kind()
              local cmp = require('cmp')

              -- IntelliJ priority order for member access
              local kind_priority = {
                [cmp.lsp.CompletionItemKind.Field] = 1,
                [cmp.lsp.CompletionItemKind.Property] = 1,
                [cmp.lsp.CompletionItemKind.Constant] = 1,
                [cmp.lsp.CompletionItemKind.EnumMember] = 1,
                [cmp.lsp.CompletionItemKind.Method] = 2,
                [cmp.lsp.CompletionItemKind.Constructor] = 3,
                [cmp.lsp.CompletionItemKind.Variable] = 4,
                [cmp.lsp.CompletionItemKind.Class] = 5,
                [cmp.lsp.CompletionItemKind.Interface] = 5,
                [cmp.lsp.CompletionItemKind.Enum] = 5,
              }

              local p1 = kind_priority[kind1] or 10
              local p2 = kind_priority[kind2] or 10

              if p1 ~= p2 then return p1 < p2 end
            end

            return nil -- Let other comparators handle it
          end, -- Then, alphabetical sorting (most important for IntelliJ feel)
          function(entry1, entry2)
            local label1 = entry1:get_completion_item().label or ''
            local label2 = entry2:get_completion_item().label or ''

            -- Case-insensitive alphabetical comparison like IntelliJ
            return label1:lower() < label2:lower()
          end, -- Fallback comparators
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
      -- Enhanced formatting for Java with inline parameters
      formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        expandable_indicator = false,
        format = function(entry, vim_item)
          local kind_icons = {
            Method = '󰊕',
            Field = '󰜢',
            Property = '󰜢',
            Constant = '󰏿',
            Class = '󰠱',
            Interface = '󰜰',
            Constructor = '󰒓',
            Variable = '󰀫',
            Enum = '󰒻',
            EnumMember = '󰒻',
            Module = '󰏗',
            Keyword = '󰌋',
          }

          -- Get completion item details
          local completion_item = entry:get_completion_item()
          local label = completion_item.label or vim_item.abbr
          local detail = completion_item.detail or ''
          local kind = vim_item.kind

          -- Set icon
          vim_item.kind = kind_icons[kind] or kind

          -- Enhanced formatting for methods and functions
          if kind == 'Method' or kind == 'Function' or kind == 'Constructor' then
            -- Extract method name and parameters from label or insertText
            local method_name = label:gsub('%(.*', '') -- Get base method name

            -- Try multiple sources for parameters
            local params_text = completion_item.insertText or label
            local params_match = params_text:match('%((.-)%)')

            -- If no parameters found in insertText, try the label
            if not params_match or params_match == '' then params_match = label:match('%((.-)%)') end

            -- If still no parameters, try detail field
            if not params_match or params_match == '' then
              if detail and detail ~= '' then params_match = detail:match('%((.-)%)') end
            end

            -- Try textEdit if available
            if not params_match or params_match == '' then
              local text_edit = completion_item.textEdit
              if text_edit and text_edit.newText then params_match = text_edit.newText:match('%((.-)%)') end
            end

            -- Clean up parameters - remove snippet syntax
            local formatted_params = ''
            if params_match and params_match ~= '' then
              local clean_params = params_match:gsub('%$%d+', ''):gsub('%${%d+:([^}]*)}', '%1')
              -- Remove any remaining snippet markers
              clean_params = clean_params:gsub('%$%{[^}]*%}', ''):gsub('%$%d+', '')
              if clean_params ~= '' then
                formatted_params = '(' .. clean_params .. ')'
              else
                formatted_params = '()'
              end
            else
              formatted_params = '()'
            end

            -- Extract return type from the detail field with robust parsing
            local return_type = ''
            if detail ~= '' then
              -- Common patterns delivered by jdtls & other servers
              local patterns = {
                '%)%s*:%s*([%w_%.%?<>%[%]]+)', -- "method(params) : ReturnType"
                '%)%s*->%s*([%w_%.%?<>%[%]]+)', -- "method(params) -> ReturnType"
                ':%s*([%w_%.%?<>%[%]]+)$', -- trailing ": ReturnType"
                '->%s*([%w_%.%?<>%[%]]+)$', -- trailing "-> ReturnType"
                '^(%S+)%s+%S+%s*%(', -- "ReturnType methodName("
              }

              for _, pattern in ipairs(patterns) do
                local match = detail:match(pattern)
                if match and match ~= '' then
                  return_type = match
                  break
                end
              end

              -- Tidy up the extracted return type
              if return_type ~= '' then
                -- Strip angle brackets around generics
                return_type = return_type:gsub('^<(.-)>$', '%1')
                -- Remove trailing "..."
                return_type = return_type:gsub('%.%.%.$', '')
                -- Simplify fully-qualified names
                if return_type:match('%.') then return_type = return_type:match('([^%.]+)$') or return_type end
              end
            end

            -- Format: "function name(int param1)                  -> void"
            -- Method name will be bold, parameters will use default styling
            vim_item.abbr = method_name .. formatted_params

            -- Use the same highlight for function name regardless of parameters
            if kind == 'Method' then
              vim_item.abbr_hl_group = 'CmpItemAbbrMethod'
            elseif kind == 'Function' then
              vim_item.abbr_hl_group = 'CmpItemAbbrFunction'
            elseif kind == 'Constructor' then
              vim_item.abbr_hl_group = 'CmpItemAbbrConstructor'
            end

            -- Show return type right-aligned in menu
            if return_type ~= '' then
              if return_type == 'void' then
                vim_item.menu = '→ void'
              else
                vim_item.menu = '→ ' .. return_type
              end
            else
              vim_item.menu = ''
            end
          elseif
            kind == 'Field'
            or kind == 'Property'
            or kind == 'Variable'
            or kind == 'Constant'
            or kind == 'EnumMember'
          then
            -- For fields, show type information
            vim_item.abbr = label

            -- Set appropriate highlight group
            if kind == 'Field' then
              vim_item.abbr_hl_group = 'CmpItemAbbrField'
            elseif kind == 'Property' then
              vim_item.abbr_hl_group = 'CmpItemAbbrProperty'
            elseif kind == 'Variable' then
              vim_item.abbr_hl_group = 'CmpItemAbbrVariable'
            elseif kind == 'Constant' or kind == 'EnumMember' then
              vim_item.abbr_hl_group = 'CmpItemAbbrConstant'
            end

            -- Show type information if available and not malformed
            if detail ~= '' and not detail:match('%.%.%.$') and not detail:match('^<%.%.%.>$') then
              vim_item.menu = '→ ' .. detail
            else
              vim_item.menu = ''
            end
          else
            -- For other kinds (Class, Interface, etc.)
            vim_item.abbr = label
            if detail ~= '' and not detail:match('%.%.%.$') then
              vim_item.menu = detail
            else
              local source_names = {
                nvim_lsp = '',
                buffer = '[Buf]',
                path = '[Path]',
              }
              vim_item.menu = source_names[entry.source.name] or ''
            end
          end

          -- Truncate long completions but preserve formatting
          if string.len(vim_item.abbr) > 50 then vim_item.abbr = string.sub(vim_item.abbr, 1, 47) .. '...' end

          if vim_item.menu and string.len(vim_item.menu) > 30 then
            vim_item.menu = string.sub(vim_item.menu, 1, 27) .. '...'
          end

          return vim_item
        end,
      },
      -- Modern, clean window configuration for Java
      window = {
        completion = {
          border = 'none',
          winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
          max_height = 15,
          max_width = 80, -- Optimal width for function name + params + return type
          col_offset = 0,
          side_padding = 1,
          scrollbar = false, -- Clean, no scrollbar
          zindex = 1001, -- Ensure popup appears above other elements
        },
        documentation = {
          border = 'none',
          max_height = 20,
          max_width = 85,
          winhighlight = 'Normal:CmpPmenu,Search:None',
          scrollbar = true, -- Enable scrollbar for documentation
          zindex = 1002, -- Documentation above completion
        },
      },
    })
  end,
}
