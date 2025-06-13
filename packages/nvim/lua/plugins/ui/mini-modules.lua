-- Mini UI modules
return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    -- Color manipulation utilities and unique colorscheme
    require('mini.colors').setup({})

    -- Show indent scope with visible guides
    require('mini.indentscope').setup({
      symbol = '│',
      options = {
        try_as_border = true,
      },
      draw = {
        delay = 100,
        animation = require('mini.indentscope').gen_animation.none(),
      },
      -- Disable for special filetypes
      filetype_exclude = {
        'lazy',
        'mason',
        'trouble',
        'neo-tree',
        'NvimTree',
        'TelescopePrompt',
        'help',
        'startify',
        'gitcommit',
        'packer',
        'lspinfo',
        'lspsagaoutline',
        'checkhealth',
        'man',
        'git',
        'prompt',
        'floaterm',
        '',
      },
    })

    -- Minimap for code overview
    require('mini.map').setup({})
  end,
}
