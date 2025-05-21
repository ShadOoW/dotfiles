-- Completion setup with nvim-cmp
return {
    "hrsh7th/nvim-cmp",
    dependencies = {"hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline",
                    "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "onsails/lspkind.nvim",
    -- Blink.cmp for advanced completion
                    {
        'saghen/blink.cmp',
        version = '1.*',
        dependencies = { -- Snippet Engine
        {
            'L3MON4D3/LuaSnip',
            version = '2.*',
            build = (function()
                -- Build Step is needed for regex support in snippets.
                -- This step is not supported in many windows environments.
                -- Remove the below condition to re-enable on windows.
                if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                    return
                end
                return 'make install_jsregexp'
            end)(),
            dependencies = {
                -- Uncomment to enable snippet collection
                -- {
                --   'rafamadriz/friendly-snippets',
                --   config = function()
                --     require('luasnip.loaders.from_vscode').lazy_load()
                --   end,
                -- },
            },
            opts = {}
        }, 'folke/lazydev.nvim'}
    }},
    event = {"InsertEnter", "CmdlineEnter"},
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        -- Try to load blink.cmp if available
        local has_blink_cmp, blink_cmp = pcall(require, "blink.cmp")

        -- Load snippets
        require("luasnip.loaders.from_vscode").lazy_load()

        -- Configure blink.cmp if available
        if has_blink_cmp then
            blink_cmp.setup({
                keymap = {
                    preset = 'default'
                },
                appearance = {
                    nerd_font_variant = 'mono'
                },
                completion = {
                    documentation = {
                        auto_show = false,
                        auto_show_delay_ms = 500
                    }
                },
                sources = {
                    default = {'lsp', 'path', 'snippets', 'lazydev'},
                    providers = {
                        lazydev = {
                            module = 'lazydev.integrations.blink',
                            score_offset = 100
                        }
                    }
                },
                snippets = {
                    preset = 'luasnip'
                },
                fuzzy = {
                    implementation = 'lua'
                },
                signature = {
                    enabled = true
                }
            })

            -- Use capabilities from blink.cmp if available
            vim.g.cmp_capabilities = blink_cmp.get_lsp_capabilities()
        end

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered()
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({
                    select = true
                }), -- Accept currently selected item
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, {"i", "s"}),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, {"i", "s"})
            }),
            sources = cmp.config.sources({{
                name = "nvim_lsp"
            }, {
                name = "luasnip"
            }, {
                name = "path"
            }}, {{
                name = "buffer"
            }}),
            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol_text",
                    maxwidth = 50,
                    ellipsis_char = "...",
                    menu = {
                        buffer = "[BUF]",
                        nvim_lsp = "[LSP]",
                        luasnip = "[SNIP]",
                        path = "[PATH]"
                    }
                })
            },
            experimental = {
                ghost_text = true
            }
        })

        -- Set up cmdline completion for different modes
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({{
                name = "path"
            }}, {{
                name = "cmdline"
            }})
        })

        cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {{
                name = "buffer"
            }}
        })
    end
}
