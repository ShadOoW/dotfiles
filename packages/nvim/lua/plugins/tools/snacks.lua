-- Snacks.nvim plugins collection by folke
-- https://github.com/folke/snacks.nvim
return {{
    "folke/snacks.nvim",
    event = "VeryLazy",
    dependencies = {"nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim"},
    config = function()
        local ok, snacks = pcall(require, "snacks")
        if not ok then
            return
        end
        snacks.setup({
            rename = {
                enable = true
            },
            bufdelete = {
                enable = true
            },
            image = {
                enable = true
            },
            styles = {
                enable = true
            },
            input = {
                enable = true
            },
            layout = {
                enable = true
            },
            notifier = {
                enable = true
            },
            notify = {
                enable = true
            },
            picker = {
                enable = true
            },
            statuscolumn = {
                enable = true
            },
            scroll = {
                enable = true
            },
            terminal = {
                enable = true
            },
            toggle = {
                enable = true
            },
            util = {
                enable = true
            },
            win = {
                enable = true
            }
        })
        vim.keymap.set("n", "<leader>bd", function()
            if snacks.bufdelete and type(snacks.bufdelete) == "table" then
                if snacks.bufdelete.delete then
                    snacks.bufdelete.delete()
                elseif snacks.bufdelete.wipe then
                    snacks.bufdelete.wipe()
                end
            else
                vim.cmd('bdelete')
            end
        end, {
            desc = "Delete buffer"
        })
    end
}}
