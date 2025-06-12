-- Mini UI modules
return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    -- Removed mini.cursorword - replaced with nvim-cursorline

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
  end,
}
