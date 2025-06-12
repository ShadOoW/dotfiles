-- Completion setup with nvim-cmp
return {
    'hrsh7th/nvim-cmp',
    dependencies = {'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline', -- For command line completion
                    'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip', 'onsails/lspkind.nvim', -- For better icons
    'rafamadriz/friendly-snippets', -- Collection of snippets
    'Exafunction/codeium.nvim' -- AI completion
    },
    event = 'InsertEnter',
    config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        local lspkind = require('lspkind')

        cmp.setup({
            -- Enable snippet support
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end
            },

            mapping = cmp.mapping.preset.insert({
                -- Arrow key navigation (as requested)
                ['<Up>'] = cmp.mapping.select_prev_item({
                    behavior = cmp.SelectBehavior.Select
                }),
                ['<Down>'] = cmp.mapping.select_next_item({
                    behavior = cmp.SelectBehavior.Select
                }),

                -- Keep Ctrl navigation as alternative
                ['<C-k>'] = cmp.mapping.select_prev_item({
                    behavior = cmp.SelectBehavior.Select
                }),
                ['<C-j>'] = cmp.mapping.select_next_item({
                    behavior = cmp.SelectBehavior.Select
                }),

                ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
                ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),

                -- Ctrl+L for snippet expansion (Tab is reserved for Codeium)
                ['<C-l>'] = cmp.mapping(function(fallback)
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, {'i', 's'}),

                -- Shift+K for snippet jumping backward only
                ['<S-k>'] = cmp.mapping(function(fallback)
                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, {'i', 's'}),

                -- Toggle completion menu with Ctrl+Space (LSP first, then buffer fallback)
                ['<C-Space>'] = cmp.mapping(function()
                    if cmp.visible() then
                        cmp.abort()
                    else
                        -- First try LSP only with snippet filtering
                        cmp.complete({
                            config = {
                                sources = {{
                                    name = 'nvim_lsp',
                                    priority = 1000,
                                    option = {
                                        -- Exclude snippets from LSP completions
                                        snippet_support = false
                                    },
                                    entry_filter = function(entry, ctx)
                                        local kind = entry:get_kind()
                                        local cmp = require('cmp')

                                        -- Filter out snippet-type completions
                                        if kind == cmp.lsp.CompletionItemKind.Snippet then
                                            return false
                                        end

                                        local completion_item = entry:get_completion_item()

                                        -- Filter out completions ending with ~ (snippet indicator)
                                        local label = completion_item.label or ''
                                        if label:match('~$') then
                                            return false
                                        end

                                        -- Filter out snippet-like characteristics
                                        if completion_item.insertTextFormat == 2 then
                                            return false
                                        end

                                        -- Filter out snippet syntax
                                        if completion_item.insertText and completion_item.insertText:match('%$%d') then
                                            return false
                                        end

                                        return true
                                    end
                                }}
                            }
                        })

                        -- If no LSP completions available, fallback to buffer after a short delay
                        vim.defer_fn(function()
                            if not cmp.visible() or #cmp.get_entries() == 0 then
                                cmp.complete({
                                    config = {
                                        sources = {{
                                            name = 'buffer',
                                            priority = 500,
                                            keyword_length = 2,
                                            option = {
                                                get_bufnrs = function()
                                                    return vim.api.nvim_list_bufs()
                                                end
                                            }
                                        }}
                                    }
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
                                sources = {{
                                    name = 'luasnip',
                                    priority = 1000
                                }, {
                                    name = 'nvim_lsp',
                                    priority = 750
                                }, {
                                    name = 'buffer',
                                    priority = 500,
                                    keyword_length = 3
                                }, {
                                    name = 'path',
                                    priority = 250
                                }}
                            }
                        })
                    end
                end),

                ['<C-e>'] = cmp.mapping.abort(), -- Close completion window

                -- ONLY Enter confirms completion
                ['<CR>'] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false -- Don't auto-select first item
                })
            }),

            -- Enhanced appearance configuration with documentation
            window = {
                completion = cmp.config.window.bordered({
                    border = 'rounded',
                    winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None'
                }),
                documentation = cmp.config.window.bordered({
                    border = 'rounded',
                    max_height = 15,
                    max_width = 60
                })
            },

            -- Minimalist formatting - only show completion text
            formatting = {
                fields = {'abbr'}, -- Only show the completion text
                format = function(entry, vim_item)
                    -- Remove all visual clutter - just the completion text
                    vim_item.menu = nil -- No source indicators
                    vim_item.kind = nil -- No icons

                    -- Keep completion text clean and simple
                    if string.len(vim_item.abbr) > 40 then
                        vim_item.abbr = string.sub(vim_item.abbr, 1, 37) .. '...'
                    end

                    return vim_item
                end
            },

            -- Performance and behavior settings
            performance = {
                debounce = 60,
                throttle = 30,
                fetching_timeout = 500
            },

            -- Completion behavior
            completion = {
                keyword_length = 1,
                completeopt = 'menu,menuone,noinsert,noselect'
            },

            -- View configuration to ensure documentation shows
            view = {
                entries = {
                    name = 'custom',
                    selection_order = 'near_cursor'
                },
                docs = {
                    auto_open = true
                }
            },

            -- DISABLED: Experimental ghost text to avoid conflicts with Codeium
            -- experimental = {
            --     ghost_text = {
            --         hl_group = 'CmpGhostText'
            --     }
            -- },

            sources = cmp.config.sources({{
                name = 'nvim_lsp',
                priority = 1000,
                max_item_count = 50, -- Limit for better performance
                -- Ensure LSP completions don't include snippets
                entry_filter = function(entry, ctx)
                    local kind = entry:get_kind()
                    local cmp = require('cmp')

                    -- Filter out snippet-type completions from LSP
                    if kind == cmp.lsp.CompletionItemKind.Snippet then
                        return false
                    end

                    local completion_item = entry:get_completion_item()

                    -- Filter out completions ending with ~ (common snippet indicator)
                    local label = completion_item.label or ''
                    if label:match('~$') then
                        return false
                    end

                    -- Additional filtering for Java files to be extra sure
                    if vim.bo.filetype == 'java' then
                        -- Filter out any completion that has snippet-like characteristics
                        if completion_item.insertTextFormat == 2 then -- InsertTextFormat.Snippet
                            return false
                        end
                        -- Filter out completions with snippet syntax (contains $1, $2, etc.)
                        if completion_item.insertText and completion_item.insertText:match('%$%d') then
                            return false
                        end
                    end

                    return true
                end
            }, {
                name = 'buffer',
                priority = 300, -- Reduced priority
                keyword_length = 4, -- Higher threshold to reduce noise
                max_item_count = 10 -- Limit buffer suggestions
            }, {
                name = 'path',
                priority = 200, -- Reduced priority
                keyword_length = 3, -- Higher threshold
                max_item_count = 5 -- Limit path suggestions
            }}, { -- Secondary group - snippets and other completions
            {
                name = 'luasnip',
                priority = 150 -- Lower priority for snippets in default completion
            }, {
                name = 'npm',
                keyword_length = 4
            }, {
                name = 'css-modules'
            }, {
                name = 'emoji',
                keyword_length = 2
            }, {
                name = 'dictionary',
                keyword_length = 2
            }})
        })

        -- Enhanced filetype-specific configurations
        cmp.setup.filetype('json', {
            sources = cmp.config.sources({{
                name = 'nvim_lsp',
                entry_filter = function(entry, ctx)
                    local kind = entry:get_kind()
                    local cmp = require('cmp')

                    -- Filter out snippet-type completions
                    if kind == cmp.lsp.CompletionItemKind.Snippet then
                        return false
                    end

                    local completion_item = entry:get_completion_item()

                    -- Filter out completions ending with ~ (snippet indicator)
                    local label = completion_item.label or ''
                    if label:match('~$') then
                        return false
                    end

                    return true
                end
            }, {
                name = 'npm'
            }}, {{
                name = 'buffer',
                keyword_length = 3
            }, {
                name = 'path'
            }})
        })

        cmp.setup.filetype({'javascript', 'typescript', 'typescriptreact', 'javascriptreact', 'html', 'css', 'scss',
                            'less'}, {
            sources = cmp.config.sources({{
                name = 'nvim_lsp',
                entry_filter = function(entry, ctx)
                    local kind = entry:get_kind()
                    local cmp = require('cmp')

                    -- Filter out snippet-type completions
                    if kind == cmp.lsp.CompletionItemKind.Snippet then
                        return false
                    end

                    local completion_item = entry:get_completion_item()

                    -- Filter out completions ending with ~ (snippet indicator)
                    local label = completion_item.label or ''
                    if label:match('~$') then
                        return false
                    end

                    return true
                end
            }, {
                name = 'luasnip'
            }, {
                name = 'css-modules'
            }}, {{
                name = 'buffer',
                keyword_length = 3
            }, {
                name = 'path'
            }})
        })

        cmp.setup.filetype('markdown', {
            sources = cmp.config.sources({{
                name = 'luasnip'
            }, {
                name = 'emoji',
                keyword_length = 2
            }, {
                name = 'dictionary',
                keyword_length = 2
            }}, {{
                name = 'buffer',
                keyword_length = 3
            }})
        })

        -- Git commit messages
        cmp.setup.filetype('gitcommit', {
            sources = cmp.config.sources({{
                name = 'buffer',
                keyword_length = 3
            }, {
                name = 'emoji',
                keyword_length = 2
            }})
        })

        -- Command line completion
        cmp.setup.cmdline({'/', '?'}, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {{
                name = 'buffer'
            }}
        })

        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({{
                name = 'path'
            }}, {{
                name = 'cmdline'
            }})
        })

        -- Custom highlight groups for better appearance
        vim.api.nvim_set_hl(0, 'CmpPmenu', {
            bg = '#1e1e2e'
        })
        vim.api.nvim_set_hl(0, 'CmpSel', {
            bg = '#45475a',
            bold = true
        })

        -- Setup snippets after everything is loaded
        vim.schedule(function()
            require('config.snippets').setup()
        end)

        -- Enhanced Java configuration for IntelliJ IDEA-like completion
        cmp.setup.filetype('java', {
            completion = {
                keyword_length = 1, -- Start completion after 1 character for better member access
                completeopt = 'menu,menuone,noinsert,noselect'
            },
            mapping = cmp.mapping.preset.insert({
                -- Standard mappings
                ['<Up>'] = cmp.mapping.select_prev_item({
                    behavior = cmp.SelectBehavior.Select
                }),
                ['<Down>'] = cmp.mapping.select_next_item({
                    behavior = cmp.SelectBehavior.Select
                }),
                ['<C-k>'] = cmp.mapping.select_prev_item({
                    behavior = cmp.SelectBehavior.Select
                }),
                ['<C-j>'] = cmp.mapping.select_next_item({
                    behavior = cmp.SelectBehavior.Select
                }),
                ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
                ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false
                }),
                -- Special mapping for dot to trigger member completion
                ['.'] = cmp.mapping(function(fallback)
                    fallback() -- Insert the dot
                    -- Trigger completion after a short delay
                    vim.defer_fn(function()
                        if cmp.visible() then
                            cmp.abort()
                        end
                        cmp.complete()
                    end, 100)
                end, {'i'})
            }),
            -- Configure sources to prioritize LSP like IntelliJ IDEA
            sources = cmp.config.sources({{
                name = 'nvim_lsp',
                priority = 1000,
                max_item_count = 50,
                -- Simplified entry filter - only filter out obvious snippets
                entry_filter = function(entry, ctx)
                    local kind = entry:get_kind()
                    local cmp = require('cmp')

                    -- Filter out snippet-type completions
                    if kind == cmp.lsp.CompletionItemKind.Snippet then
                        return false
                    end

                    local completion_item = entry:get_completion_item()
                    local label = completion_item.label or ''

                    -- Filter out completions ending with ~ (snippet indicator)
                    if label:match('~$') then
                        return false
                    end

                    -- Filter out obvious snippet syntax
                    if completion_item.insertText and completion_item.insertText:match('%$%d') then
                        return false
                    end

                    return true
                end
            }}, {{
                name = 'buffer',
                priority = 200,
                keyword_length = 4,
                max_item_count = 5,
                option = {
                    get_bufnrs = function()
                        -- Only search current Java buffer
                        local current_buf = vim.api.nvim_get_current_buf()
                        if vim.bo[current_buf].filetype == 'java' then
                            return {current_buf}
                        end
                        return {}
                    end
                }
            }, {
                name = 'path',
                priority = 100,
                keyword_length = 3,
                max_item_count = 3
            }}),
            -- Enhanced formatting for Java
            formatting = {
                fields = {'kind', 'abbr', 'menu'},
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
                        Keyword = '󰌋'
                    }

                    -- Set icon
                    vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind

                    -- Set source indicator (make LSP more prominent)
                    local source_names = {
                        nvim_lsp = '', -- No indicator for LSP to keep it clean
                        buffer = '[Buf]',
                        path = '[Path]'
                    }
                    vim_item.menu = source_names[entry.source.name] or '[?]'

                    -- Truncate long completions
                    if string.len(vim_item.abbr) > 40 then
                        vim_item.abbr = string.sub(vim_item.abbr, 1, 37) .. '...'
                    end

                    return vim_item
                end
            },
            -- Enhanced window configuration for Java
            window = {
                completion = cmp.config.window.bordered({
                    border = 'rounded',
                    winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
                    max_height = 15,
                    max_width = 60
                }),
                documentation = cmp.config.window.bordered({
                    border = 'rounded',
                    max_height = 20,
                    max_width = 80
                })
            }
        })
    end
}
