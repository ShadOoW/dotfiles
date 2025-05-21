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

        -- Add/delete/replace surroundings
        require('mini.surround').setup({})

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
