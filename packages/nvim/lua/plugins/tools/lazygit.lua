-- Lazygit integration for easy Git management
return {
  'kdheepak/lazygit.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
  keys = {
    {
      '<leader>gg',
      '<cmd>LazyGit<cr>',
      desc = 'LazyGit',
    },
    {
      '<leader>gG',
      '<cmd>LazyGitCurrentFile<cr>',
      desc = 'LazyGit current file',
    },
  },
  config = function()
    -- Configure lazygit
    vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
    vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
    vim.g.lazygit_floating_window_border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' } -- customize lazygit popup window border characters
    vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
    vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed
    vim.g.lazygit_use_custom_config_file_path = 0 -- config file path is evaluated if this value is 1
    vim.g.lazygit_config_file_path = '' -- custom config file path

    -- Additional keymaps for git operations
    vim.keymap.set('n', '<leader>gc', '<cmd>LazyGitFilter<cr>', {
      desc = 'LazyGit commits',
    })
    vim.keymap.set('n', '<leader>gf', '<cmd>LazyGitFilterCurrentFile<cr>', {
      desc = 'LazyGit current file history',
    })

    -- Integration with terminal (avoiding conflict with LSP goto type definitions)
    vim.keymap.set('n', '<leader>gT', function()
      -- Open lazygit in a terminal buffer
      vim.cmd('terminal lazygit')
    end, {
      desc = 'LazyGit in terminal',
    })
  end,
}
