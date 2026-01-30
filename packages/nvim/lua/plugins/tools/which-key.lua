return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  config = function()
    local wk = require('which-key')

    -- Configure which-key
    wk.setup({
      delay = 0,
      icons = {
        mappings = false,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          -- Add more key mappings as needed
        },
      },
      spec = {
        {
          '<leader>w',
          group = 'Window',
        },
        {
          '<leader>c',
          group = 'Code',
        },
        {
          '<leader>f',
          group = 'File',
        },
        {
          '<leader>s',
          group = 'Search',
        },
        {
          '<leader>S',
          group = 'Session',
        },
        {
          '<leader>b',
          group = 'Buffers',
        },
        {
          '<leader>e',
          group = 'Editor',
        },
        {
          '<leader>g',
          group = 'LSP',
        },
        {
          '<leader>t',
          group = 'Tags & Symbols',
        },
        {
          '<leader>x',
          group = 'Panels',
        },
        {
          '<leader>a',
          group = 'Notes & Journal',
        },
        {
          '<leader>z',
          group = 'File Type',
        },
        {
          '<leader>1',
          group = 'Tab [1-9]',
        },
        {
          '<leader><Right>',
          group = ' Next & Previous Buffer ',
        },
        {
          '<leader><Up>',
          group = ' Next & Previous Tab ',
        },
        {
          '<leader>1',
          desc = 'Tab 1',
          hidden = true,
        },
        {
          '<leader>2',
          desc = 'Tab 2',
          hidden = true,
        },
        {
          '<leader>3',
          desc = 'Tab 3',
          hidden = true,
        },
        {
          '<leader>4',
          desc = 'Tab 4',
          hidden = true,
        },
        {
          '<leader>5',
          desc = 'Tab 5',
          hidden = true,
        },
        {
          '<leader>6',
          desc = 'Tab 6',
          hidden = true,
        },
        {
          '<leader>7',
          desc = 'Tab 7',
          hidden = true,
        },
        {
          '<leader>8',
          desc = 'Tab 8',
          hidden = true,
        },
        {
          '<leader>9',
          desc = 'Tab 9',
          hidden = true,
        },
        {
          '<leader><Down>',
          desc = 'Previous Tab',
          hidden = true,
        },
        {
          '<leader><Left>',
          desc = 'Previous Buffer',
          hidden = true,
        },
        {
          '<leader><Right>',
          desc = 'Next Buffer',
          hidden = true,
        },
        {
          '<leader><Up>',
          desc = 'Next Tab',
          hidden = true,
        },
      },
    })
  end,
}
