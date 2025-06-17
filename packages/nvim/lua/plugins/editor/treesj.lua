-- TreeSJ - Better code splitting and joining with tree-sitter awareness
return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('treesj').setup({
      -- Use default keymaps
      use_default_keymaps = false,
      -- Check syntax errors
      check_syntax_error = true,
      -- Maximum join line length
      max_join_length = 120,
      -- Cursor behavior
      cursor_behavior = 'hold', -- 'hold' | 'start' | 'end'
      -- Notify about possible syntax errors
      notify = true,
      -- Configure dot repeat
      dot_repeat = true,
      -- Configure join and split behaviors
      opts = {
        ignore_comments = true,
      },
    })

    -- Custom keymaps
    vim.keymap.set('n', '<leader>tj', function() require('treesj').toggle() end, {
      desc = 'TreeSJ Toggle Split/Join',
    })

    vim.keymap.set('n', '<leader>ts', function() require('treesj').split() end, {
      desc = 'TreeSJ Split',
    })

    vim.keymap.set('n', '<leader>tk', function() require('treesj').join() end, {
      desc = 'TreeSJ Join',
    })
  end,
}
