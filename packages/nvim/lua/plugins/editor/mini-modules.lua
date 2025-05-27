-- Mini editing modules
return {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
        -- Core Editing Features
        -- Autopairs for brackets, quotes, etc.
        require('mini.pairs').setup({})

        -- Split or join arguments, lists, tables, etc.
        require('mini.splitjoin').setup({})

        -- Navigate by brackets and other items
        require('mini.bracketed').setup({})

        -- Add/delete/replace surroundings (enhanced version)
        require('mini.surround').setup({
            -- Add custom surroundings here if needed
            mappings = {
                add = 'sa', -- Add surrounding in Normal and Visual modes
                delete = 'sd', -- Delete surrounding
                find = 'sf', -- Find surrounding (to the right)
                find_left = 'sF', -- Find surrounding (to the left)
                highlight = 'sh', -- Highlight surrounding
                replace = 'sr', -- Replace surrounding
                update_n_lines = 'sn' -- Update `n_lines`
            }
        })

        -- Enhanced text objects and motions
        require('mini.ai').setup({
            -- Search method can be 'cover', 'cover_or_next', 'cover_or_prev', 'next', 'prev'
            search_method = 'cover_or_next',
            -- Custom text objects can be added here
            custom_textobjects = {
                -- Add your custom text objects here if needed
            }
        })

        -- File explorer
        local files_win_config = nil
        require('mini.files').setup({
            -- Customize windows
            windows = {
                preview = true,
                width_focus = 30,
                width_preview = 40
            },
            -- Customize content
            content = {
                -- Predicate for which files to show
                filter = nil,
                -- Prefix to show before item
                prefix = nil,
                -- Show only last component of path
                show_prefix = false
            },
            mappings = {
                go_in = '<CR>',
                go_in_plus = '<C-CR>',
                go_out = '-',
                go_out_plus = '_',
                show_help = 'g?',
                synchronize = '=',
                trim_left = '<',
                trim_right = '>',
                close = 'q' -- Add q to close
            },
            options = {
                -- Don't use netrw (prevents neo-tree from opening)
                use_as_default_explorer = true
            }
        })

        -- Set up the keymapping for mini.files
        vim.keymap.set("n", "<leader>fe", function()
            if files_win_config then
                -- If mini.files is open, close it
                require("mini.files").close()
                files_win_config = nil
            else
                -- Store window config when opening
                files_win_config = require("mini.files").open(vim.api.nvim_buf_get_name(0))
            end
        end, {
            desc = "Toggle MiniFiles"
        })

        -- Add a dedicated close keymap
        vim.keymap.set("n", "<leader>fc", function()
            require("mini.files").close()
            files_win_config = nil
        end, {
            desc = "Close MiniFiles"
        })

        -- Movement & Navigation
        -- Jump to locations based on first typed character
        require('mini.jump').setup({})

        -- Jump to any visible location with two-character input
        require('mini.jump2d').setup({})

        -- Track and visit recent files and buffers
        require('mini.visits').setup({})

        -- File and Session Management
        -- Simple session management
        require('mini.sessions').setup({
            -- Auto-write current session
            autowrite = true,
            -- Directory to store sessions
            directory = vim.fn.stdpath('data') .. '/sessions'
        })

        -- Utilities & Extras
        -- Remove buffers without losing window layout
        require('mini.bufremove').setup({})
    end
}
