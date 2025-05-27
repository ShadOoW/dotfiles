-- Dashboard configuration
return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  dependencies = {
    {
      'nvim-tree/nvim-web-devicons',
    },
  },
  config = function()
    require('dashboard').setup({
      theme = 'doom',
      config = {
        header = {
          '',
          '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
          '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
          '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
          '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
          '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
          '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
          '',
          '                 [ Mini.nvim Edition ]              ',
          '',
        },
        center = {
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Find File',
            desc_hl = 'String',
            key = 'f',
            key_hl = 'Number',
            action = 'Telescope find_files',
          },
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Recent Files',
            desc_hl = 'String',
            key = 'r',
            key_hl = 'Number',
            action = 'Telescope oldfiles',
          },
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Find Word',
            desc_hl = 'String',
            key = 'g',
            key_hl = 'Number',
            action = 'Telescope live_grep',
          },
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'New File',
            desc_hl = 'String',
            key = 'n',
            key_hl = 'Number',
            action = 'enew',
          },
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Load Session',
            desc_hl = 'String',
            key = 's',
            key_hl = 'Number',
            action = 'lua require("mini.sessions").read()',
          },
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Config',
            desc_hl = 'String',
            key = 'c',
            key_hl = 'Number',
            action = 'e ~/.config/nvim/init.lua',
          },
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Quit',
            desc_hl = 'String',
            key = 'q',
            key_hl = 'Number',
            action = 'qa',
          },
        },
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return {
            '⚡ Neovim loaded ' .. stats.count .. ' plugins in ' .. ms .. 'ms',
          }
        end,
      },
    })
  end,
}
