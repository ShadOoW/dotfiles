-- Markdown preview in webview window (not external browser)
-- Live markdown preview with automatic reload
return {
  'toppair/peek.nvim',
  build = 'deno task --quiet build:fast',
  cmd = { 'PeekOpen', 'PeekClose' },
  ft = { 'markdown', 'obsidian' },
  config = function()
    require('peek').setup({
      auto_load = true, -- automatically load preview when entering markdown buffer
      close_on_bdelete = true, -- close preview window on buffer delete
      syntax = true, -- enable syntax highlighting
      theme = 'dark', -- 'dark' or 'light'
      update_on_change = true,
      app = 'webview', -- 'webview' opens in a separate window, not external browser
      filetype = { 'markdown', 'obsidian' }, -- list of filetypes to recognize as markdown
      -- Custom function to open in floating window instead of external browser
      throttle_at = 200000, -- start throttling when file exceeds this amount of bytes
      throttle_time = 'auto', -- minimum amount of time in milliseconds that has to pass before starting new render
    })

    -- Keymaps for peek using direct function calls
    vim.keymap.set('n', '<leader>po', function() require('peek').open() end, {
      desc = 'Open peek preview',
    })
    vim.keymap.set('n', '<leader>pc', function() require('peek').close() end, {
      desc = 'Close peek preview',
    })
  end,
}
