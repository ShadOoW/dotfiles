return { -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {"stevearc/conform.nvim", "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim",
                    "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline",
                    "hrsh7th/nvim-cmp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "j-hui/fidget.nvim"},
    config = function()
        -- Initialize LSP setup from lsp/setup.lua
        require('lsp.setup').setup()

        -- Ensure the servers and tools are installed
        require('mason-tool-installer').setup {
            ensure_installed = {'lua-language-server', 'stylua', -- Used to format Lua code
            'jdtls', -- Java language server
            'java-debug-adapter', -- Java debugger
            'java-test', -- Java test runner
            'checkstyle', -- Java style checker
            'google-java-format' -- Java formatter
            }
        }

        require('mason-lspconfig').setup {
            ensure_installed = {'jdtls'},
            automatic_installation = true
        }
    end
}
