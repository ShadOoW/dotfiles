return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/nvim-nio', -- Add adapters as needed, e.g. 'nvim-neotest/neotest-python', etc.
  },
  config = function()
    require('neotest').setup({
      -- Example: add adapters here
      -- adapters = {
      --     require('neotest-python')({ dap = { justMyCode = false } }),
      --     require('neotest-plenary'),
      --     require('neotest-vim-test')({ ignore_file_types = { "python", "vim", "lua" } }),
      -- },
    })
  end,
}
