-- yanky.nvim: Improved yank and put functionality
return {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    dependencies = {"nvim-telescope/telescope.nvim"},
    config = function()
        -- Basic yanky setup without telescope-specific options
        require("yanky").setup({
            ring = {
                history_length = 100,
                storage = "memory",
                sync_with_numbered_registers = true,
                cancel_event = "update"
            },
            picker = {
                select = {
                    action = nil -- Use default action
                }
            },
            system_clipboard = {
                sync_with_ring = true
            },
            highlight = {
                on_put = true,
                on_yank = true,
                timer = 500
            },
            preserve_cursor_position = {
                enabled = true
            }
        })

        -- Basic yanky mappings (these don't depend on telescope)
        vim.keymap.set({"n", "x"}, "y", "<Plug>(YankyYank)", {
            desc = "Yank text"
        })
        vim.keymap.set({"n", "x"}, "p", "<Plug>(YankyPutAfter)", {
            desc = "Put after cursor"
        })
        vim.keymap.set({"n", "x"}, "P", "<Plug>(YankyPutBefore)", {
            desc = "Put before cursor"
        })
        vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)", {
            desc = "Cycle forward through yank history"
        })
        vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)", {
            desc = "Cycle backward through yank history"
        })

        -- Defer telescope integration to ensure both plugins are fully loaded
        vim.defer_fn(function()
            -- Safely check if telescope is available
            local status_ok, telescope = pcall(require, "telescope")
            if not status_ok then
                return
            end

            -- Safely try to load the extension
            local success, _ = pcall(function()
                telescope.load_extension("yank_history")
            end)

            if success then
                -- Only set up the keymap if extension loaded successfully
                vim.keymap.set("n", "<leader>fy", "<cmd>Telescope yank_history<CR>", {
                    desc = "Search through yank history"
                })
            end
        end, 200) -- Longer delay to ensure everything is loaded
    end
}
