-- Autocommands
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', {
    clear = true,
  }),
  callback = function() vim.highlight.on_yank() end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Disable document highlight for file types that often cause issues
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'markdown',
    'text',
    'txt',
    'help',
    'log',
    'json',
    'yaml',
    'toml',
    'conf',
  },
  callback = function(args)
    -- Clear any existing document highlight autocommands for this buffer
    vim.api.nvim_clear_autocmds({
      group = 'lsp-document-highlight-' .. args.buf,
      buffer = args.buf,
    })
  end,
  desc = 'Disable document highlight for specific file types',
})

-- Auto-indent and split tags on <CR> in HTML-like files
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'html',
    'xml',
    'typescriptreact',
    'javascriptreact',
    'tsx',
    'jsx',
    'astro',
  },
  callback = function()
    vim.keymap.set('i', '<CR>', function()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = vim.api.nvim_get_current_line()
      if col > 0 and line:sub(col, col) == '>' and line:sub(col + 1, col + 1) == '<' then
        return '<CR><CR><Up><C-f>'
      else
        return '<CR>'
      end
    end, {
      expr = true,
      buffer = true,
    })
  end,
})
