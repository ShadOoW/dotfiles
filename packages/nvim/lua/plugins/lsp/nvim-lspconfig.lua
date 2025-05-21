return { -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = { -- Automatically install LSPs and related tools to stdpath for Neovim
    {
        'mason-org/mason.nvim',
        opts = {}
    }, 'mason-org/mason-lspconfig.nvim', 'WhoIsSethDaniel/mason-tool-installer.nvim', -- Useful status updates for LSP
    {
        'j-hui/fidget.nvim',
        opts = {}
    }},
    config = function()
        -- Initialize LSP setup from lsp/setup.lua
        require('lsp.setup').setup()

        -- Ensure the servers and tools are installed
        require('mason-tool-installer').setup {
            ensure_installed = {'lua-language-server', 'stylua' -- Used to format Lua code
            }
        }

        require('mason-lspconfig').setup {
            ensure_installed = {},
            automatic_installation = false
        }
    end
}
