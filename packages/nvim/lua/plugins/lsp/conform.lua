return {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
        format_on_save = true,
        formatters_by_ft = {
            html = {"prettier"},
            css = {"prettier"},
            typescript = {"prettier"},
            typescriptreact = {"prettier"},
            astro = {"prettier"},
            javascript = {"prettier"},
            javascriptreact = {"prettier"},
            lua = {"stylua"}
            -- Add rustywind for tailwind class sorting if desired
        },
        formatters = {
            rustywind = {
                command = "rustywind",
                args = {"--stdin"},
                stdin = true
            }
        }
    }
}
