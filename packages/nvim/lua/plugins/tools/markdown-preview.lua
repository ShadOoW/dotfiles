-- Markdown preview with browser fallback using utils
local browser_utils = require('utils.browser')

local plugin_spec = {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = { 'markdown', 'obsidian' },
  build = function() vim.fn['mkdp#util#install']() end,
  config = function()
    -- Configure markdown-preview.nvim
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_command_for_global = 0
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_open_ip = '127.0.0.1'
    vim.g.mkdp_port = '2003'
    vim.g.mkdp_browser = ''
    vim.g.mkdp_echo_preview_url = 1
    vim.g.mkdp_filetypes = { 'markdown', 'obsidian' }

    -- Set up custom browser function using vim script that calls our lua function directly
    vim.cmd([[
      function! g:OpenMarkdownPreview(url)
        lua require('utils.browser').open_markdown_preview(vim.fn.eval('a:url'))
      endfunction
    ]])

    -- Set the browser function
    vim.g.mkdp_browserfunc = 'g:OpenMarkdownPreview'

    -- General keymaps
    vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', {
      desc = 'Toggle markdown preview',
    })
    vim.keymap.set('n', '<leader>ms', '<cmd>MarkdownPreviewStop<cr>', {
      desc = 'Stop markdown preview',
    })

    -- Obsidian-specific keymaps (for obsidian files)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'obsidian',
      callback = function()
        vim.keymap.set('n', '<leader>omp', '<cmd>MarkdownPreviewToggle<cr>', {
          desc = 'Toggle markdown preview (browser)',
          buffer = true,
        })
        vim.keymap.set('n', '<leader>oms', '<cmd>MarkdownPreviewStop<cr>', {
          desc = 'Stop markdown preview',
          buffer = true,
        })
        vim.keymap.set('n', '<leader>omr', '<cmd>MarkdownPreview<cr>', {
          desc = 'Start markdown preview',
          buffer = true,
        })
      end,
    })
  end,
}

return plugin_spec
