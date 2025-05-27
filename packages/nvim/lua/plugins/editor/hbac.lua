-- Healthy Buffer Auto-Close (HBAC)
-- Automatically close unmodified buffers when the number gets too high
return {
    "axkirillov/hbac.nvim",
    event = "VeryLazy",
    config = function()
        local hbac = require("hbac")

        hbac.setup({
            -- Close buffers that haven't been viewed for this amount of time (in minutes)
            autoclose_if_unused_for = 30,

            -- Maximum number of unmodified buffers to keep
            threshold = 5,

            -- Never close these filetypes
            close_buffers_with_windows = false,

            -- Filetypes to ignore
            ignore_filetypes = {"help", "Trouble", "dashboard", "toggleterm", "DiffviewFiles", "DiffviewFileHistory",
                                "qf", "TelescopePrompt", "TelescopeResults"},

            -- Buffer types to ignore
            ignore_buftypes = {"help", "nofile", "quickfix", "terminal", "prompt"}
        })

        -- Add mappings for hbac
        vim.keymap.set("n", "<leader>hc", function()
            hbac.close_all_unpinned_buffers()
        end, {
            desc = "Close all unpinned buffers"
        })
        vim.keymap.set("n", "<leader>hp", function()
            hbac.toggle_pin()
        end, {
            desc = "Toggle pin buffer"
        })
    end
}
