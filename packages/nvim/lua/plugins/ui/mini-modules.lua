-- Mini UI modules
return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    -- UI/Visual Enhancements
    -- Smooth animation for common Neovim actions
    require('mini.animate').setup({})

    -- Highlight word under cursor
    require('mini.cursorword').setup({})

    -- Color manipulation utilities and unique colorscheme
    require('mini.colors').setup({})

    -- Show indent scope with visible guides
    require('mini.indentscope').setup({
      symbol = '│',
      options = {
        try_as_border = true,
      },
    })

    -- Minimap for code overview
    require('mini.map').setup({})

    -- Minimal and customizable statusline
    require('mini.statusline').setup({
      use_icons = vim.g.have_nerd_font,
    })

    -- Minimal and customizable tabline
    require('mini.tabline').setup({
      show_icons = vim.g.have_nerd_font,
    })

    -- Highlight trailing whitespace
    require('mini.trailspace').setup({})
  end,
}
