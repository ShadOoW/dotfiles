-- terminal.lua: Floating/split terminal via toggleterm.nvim
-- Managed by the bottom panel system (<leader>xt to toggle)
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  lazy = true,
  cmd = 'ToggleTerm',
  config = function()
    require('toggleterm').setup({
      size = 12,
      direction = 'horizontal',
      shade_terminals = false,
      start_in_insert = true,
      insert_mappings = false,
      terminal_mappings = false,
      persist_size = true,
      persist_mode = false,
      close_on_exit = false,
      shell = vim.o.shell,
      auto_scroll = true,
      highlights = {
        Normal = { link = 'Normal' },
        NormalFloat = { link = 'NormalFloat' },
        FloatBorder = { link = 'FloatBorder' },
      },
    })

    -- Exit terminal mode back to normal with Escape
    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
  end,
}
