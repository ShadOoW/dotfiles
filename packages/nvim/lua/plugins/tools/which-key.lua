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
          '<leader>f',
          group = 'File',
        },
        {
          '<leader>F',
          group = 'File Operations',
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
          '<leader>A',
          group = 'Admin',
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
          '<leader>p',
          group = 'Panels',
        },
        {
          '<leader>a',
          group = 'Wiki & Journal',
        },
        {
          '<leader>d',
          group = 'Debug',
        },
        {
          '<leader>h',
          group = 'Git',
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
      },
    })

    -- Hide individual leader+1 to leader+9 keys
    wk.register({
      ['<leader>1'] = 'Tab 1',
      ['<leader>2'] = 'Tab 2',
      ['<leader>3'] = 'Tab 3',
      ['<leader>4'] = 'Tab 4',
      ['<leader>5'] = 'Tab 5',
      ['<leader>6'] = 'Tab 6',
      ['<leader>7'] = 'Tab 7',
      ['<leader>8'] = 'Tab 8',
      ['<leader>9'] = 'Tab 9',
      ['<leader><Right>'] = 'Next Buffer',
      ['<leader><Left>'] = 'Previous Buffer',
      ['<leader><Up>'] = 'Next Tab',
      ['<leader><Down>'] = 'Previous Tab',
    }, {
      mode = 'n',
      hidden = true,
    })
  end,
}
