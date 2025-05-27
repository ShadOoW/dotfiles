-- output-panel.nvim: Show command output in a panel
return {
    "mhanberg/output-panel.nvim",
    event = "VeryLazy",
    config = function()
        require("output_panel").setup({
            -- Width of the panel (can be a number or a string)
            width = 80,

            -- Height of the panel
            height = 10,

            -- Position of the panel
            position = "bottom",

            -- Border style
            border = "rounded",

            -- Filetype for the buffer
            filetype = "output-panel",

            -- Auto-close the panel when it loses focus
            auto_close = false,

            -- Auto-open the panel when a command runs
            auto_open = false
        })

        -- Add keymaps for output panel
        vim.keymap.set("n", "<leader>fo", "<cmd>OutputPanel toggle<CR>", {
            desc = "Toggle output panel"
        })
    end
}
