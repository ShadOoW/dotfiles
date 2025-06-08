-- Mini UI modules
return {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
        -- Highlight word under cursor
        require('mini.cursorword').setup({})

        -- Color manipulation utilities and unique colorscheme
        require('mini.colors').setup({})

        -- Show indent scope with visible guides
        require('mini.indentscope').setup({
            symbol = '│',
            options = {
                try_as_border = true
            }
        })

        -- Minimap for code overview
        require('mini.map').setup({})

        -- Minimal and customizable tabline
        require('mini.tabline').setup({
            show_icons = vim.g.have_nerd_font
        })

        -- Highlight trailing whitespace
        require('mini.trailspace').setup({})
    end
}
