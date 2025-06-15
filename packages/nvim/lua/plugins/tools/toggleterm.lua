-- ToggleTerm: Terminal integration for Neovim
-- Used by Overseer for task output
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    -- Size can be a number or function which is passed the current terminal
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<C-\>]],
    hide_numbers = true, -- Hide the number column in toggleterm buffers
    shade_filetypes = {},
    autochdir = false, -- When neovim changes it current directory the terminal will change it's own when next it's opened
    shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
    shading_factor = 2, -- The degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- Whether or not the open mapping applies in insert mode
    terminal_mappings = true, -- Whether or not the open mapping applies in the opened terminals
    persist_size = true,
    persist_mode = true, -- If set to true (default) the previous terminal mode will be remembered
    direction = 'horizontal',
    close_on_exit = true, -- Close the terminal window when the process exits
    shell = vim.o.shell, -- Change the default shell
    auto_scroll = true, -- Automatically scroll to the bottom on terminal output
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      border = 'curved',
      winblend = 0,
      highlights = {
        border = 'Normal',
        background = 'Normal',
      },
    },
    winbar = {
      enabled = false,
      name_formatter = function(term) -- term: Terminal
        return term.name
      end,
    },
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    -- Set terminal keymaps
    function _G.set_terminal_keymaps()
      local opts = {
        buffer = 0,
      }
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    end

    -- Apply terminal keymaps when terminal opens
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

    -- Custom terminal functions
    local Terminal = require('toggleterm.terminal').Terminal

    -- Floating terminal
    local float_term = Terminal:new({
      direction = 'float',
      float_opts = {
        border = 'double',
      },
      -- function to run on opening the terminal
      on_open = function(term)
        vim.cmd('startinsert!')
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', {
          noremap = true,
          silent = true,
        })
      end,
      -- function to run on closing the terminal
      on_close = function(term) vim.cmd('startinsert!') end,
    })

    -- Lazy git terminal
    local lazygit = Terminal:new({
      cmd = 'lazygit',
      dir = 'git_dir',
      direction = 'float',
      float_opts = {
        border = 'double',
      },
      hidden = true,
      -- function to run on opening the terminal
      on_open = function(term)
        vim.cmd('startinsert!')
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', {
          noremap = true,
          silent = true,
        })
      end,
      -- function to run on closing the terminal
      on_close = function(term) vim.cmd('startinsert!') end,
    })

    -- Node terminal
    local node = Terminal:new({
      cmd = 'node',
      hidden = true,
    })

    -- Python terminal
    local python = Terminal:new({
      cmd = 'python',
      hidden = true,
    })

    -- Define terminal toggle functions
    function _FLOAT_TOGGLE() float_term:toggle() end

    function _LAZYGIT_TOGGLE() lazygit:toggle() end

    function _NODE_TOGGLE() node:toggle() end

    function _PYTHON_TOGGLE() python:toggle() end

    -- ToggleTerm keymaps
    vim.keymap.set('n', '<leader>tf', '<cmd>lua _FLOAT_TOGGLE()<CR>', {
      desc = 'Float Terminal',
    })
    vim.keymap.set('n', '<leader>tg', '<cmd>lua _LAZYGIT_TOGGLE()<CR>', {
      desc = 'LazyGit',
    })
    vim.keymap.set('n', '<leader>tn', '<cmd>lua _NODE_TOGGLE()<CR>', {
      desc = 'Node',
    })
    vim.keymap.set('n', '<leader>tp', '<cmd>lua _PYTHON_TOGGLE()<CR>', {
      desc = 'Python',
    })

    -- General terminal toggles
    vim.keymap.set('n', '<leader>th', '<cmd>ToggleTerm size=10 direction=horizontal<cr>', {
      desc = 'Horizontal Terminal',
    })
    vim.keymap.set('n', '<leader>tv', '<cmd>ToggleTerm size=80 direction=vertical<cr>', {
      desc = 'Vertical Terminal',
    })
  end,
}
