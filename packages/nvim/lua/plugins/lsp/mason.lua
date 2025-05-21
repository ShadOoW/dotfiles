-- Mason for LSP, DAP, and Linter installation
return {
    "williamboman/mason.nvim",
    dependencies = {"williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig", "jay-babu/mason-nvim-dap.nvim"},
    config = function()
        require("mason").setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
        })

        -- Configure Mason LSP
        require("mason-lspconfig").setup({
            ensure_installed = { -- Web Development
            "html", -- HTML
            "cssls", -- CSS
            "typescript-language-server", -- TypeScript/JavaScript (ts_ls)
            "eslint", -- ESLint
            "tailwindcss", -- Tailwind CSS
            "astro", -- Astro
            "emmet_ls", -- Emmet
            "jsonls", -- JSON
            "yamlls", -- YAML
            "denols", -- Deno
            -- Java Development
            "jdtls", -- Java
            -- C/C++ Development
            "clangd", -- C/C++/Objective-C
            -- General
            "lua_ls", -- Lua
            "marksman", -- Markdown
            "bashls", -- Bash
            "dockerls" -- Docker
            },
            automatic_installation = true
        })

        -- Configure Mason DAP
        require("mason-nvim-dap").setup({
            ensure_installed = {"codelldb"},
            automatic_installation = true,
            handlers = {
                ["codelldb"] = function(config)
                    config.configurations = {{
                        type = "lldb",
                        name = "Debug (Launch)",
                        request = "launch",
                        program = function()
                            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                        end,
                        cwd = "${workspaceFolder}",
                        stopOnEntry = false,
                        args = {}
                    }, {
                        type = "lldb",
                        name = "Debug (Attach)",
                        request = "attach",
                        pid = function()
                            return tonumber(vim.fn.input("Pid: "))
                        end
                    }}
                    require("mason-nvim-dap").default_setup(config)
                end
            }
        })
    end
}
