-- LSP servers configuration
return {
    "neovim/nvim-lspconfig",
    dependencies = {"hrsh7th/cmp-nvim-lsp", "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim"},
    event = {"BufReadPre", "BufNewFile"},
    config = function()
        -- Configure LSP servers
        local lspconfig = require("lspconfig")
        local handlers = require("lsp.handlers")

        -- Common LSP settings
        local common_settings = {
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
            on_attach = handlers.on_attach
        }

        -- Configure individual LSP servers
        lspconfig.html.setup(common_settings)
        lspconfig.cssls.setup(common_settings)
        -- Using ts_ls instead of deprecated tsserver
        lspconfig.typescript.setup(common_settings)
        lspconfig.eslint.setup(common_settings)
        lspconfig.tailwindcss.setup(common_settings)
        lspconfig.astro.setup(common_settings)
        lspconfig.emmet_ls.setup(common_settings)
        lspconfig.jsonls.setup(common_settings)
        lspconfig.yamlls.setup(common_settings)
        lspconfig.marksman.setup(common_settings)
        lspconfig.bashls.setup(common_settings)
        lspconfig.dockerls.setup(common_settings)
        lspconfig.denols.setup(common_settings)
        lspconfig.clangd.setup(common_settings)

        -- Lua specific configuration
        lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", common_settings, {
            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT'
                    },
                    diagnostics = {
                        globals = {'vim'}
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false
                    },
                    telemetry = {
                        enable = false
                    },
                    completion = {
                        callSnippet = "Replace"
                    }
                }
            }
        }))

        -- Java specific configuration
        lspconfig.jdtls.setup(vim.tbl_deep_extend("force", common_settings, {
            settings = {
                java = {
                    configuration = {
                        runtimes = {{
                            name = "JavaSE-17",
                            path = "/usr/lib/jvm/java-17-openjdk",
                            default = true
                        }, {
                            name = "JavaSE-1.8",
                            path = "/usr/lib/jvm/java-8-openjdk"
                        }}
                    },
                    format = {
                        settings = {
                            url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
                            profile = "GoogleStyle"
                        }
                    },
                    debug = {
                        vmArgs = "-ea"
                    }
                }
            }
        }))
    end
}
