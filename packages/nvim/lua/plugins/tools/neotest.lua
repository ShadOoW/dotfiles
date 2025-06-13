-- Test runner framework
-- Provides a unified interface for running tests
return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/nvim-nio', -- Add adapters as needed:
    -- 'nvim-neotest/neotest-python',
    -- 'nvim-neotest/neotest-plenary',
    -- 'nvim-neotest/neotest-vim-test',
  },
  config = function()
    require('neotest').setup({
      -- adapters = {
      --   require('neotest-python')({ dap = { justMyCode = false } }),
      --   require('neotest-plenary'),
      --   require('neotest-vim-test')({ ignore_file_types = { 'python', 'vim', 'lua' } }),
      -- },
    })
  end,
}
