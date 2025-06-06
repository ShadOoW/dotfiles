return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'TroubleToggle', 'Trouble' },
  config = function()
    local trouble = require('trouble')
    trouble.setup({
      position0 = 'bottom',
      height = 10,
      icons = true,
      mode = 'workspace_diagnostics',
      fold_open = '',
      fold_closed = '',
      group = true,
      padding = true,
      action_keys = {
        close = 'q',
        cancel = '<esc>',
        refresh = 'r',
        jump = { '<cr>', '<tab>' },
        open_split = { '<c-x>' },
        open_vsplit = { '<c-v>' },
        open_tab = { '<c-t>' },
        jump_close = { 'o' },
        toggle_mode = 'm',
        toggle_preview = 'P',
        hover = 'K',
        preview = 'p',
        close_folds = { 'zM', 'zm' },
        open_folds = { 'zR', 'zr' },
        toggle_fold = { 'zA', 'za' },
        previous = 'k',
        next = 'j',
      },
      indent_lines = true,
      auto_open = false,
      auto_close = false,
      auto_preview = true,
      auto_fold = false,
      auto_jump = { 'lsp_definitions' },
      signs = {
        error = '',
        warning = '',
        hint = '',
        information = '',
        other = '﫠',
      },
      use_diagnostic_signs = false,
    })

    -- Set up keymaps
    vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle<cr>', {
      desc = 'Toggle Trouble',
    })
    vim.keymap.set('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', {
      desc = 'Workspace Diagnostics',
    })
    vim.keymap.set('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', {
      desc = 'Document Diagnostics',
    })
    vim.keymap.set('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', {
      desc = 'Location List',
    })
    vim.keymap.set('n', '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', {
      desc = 'Quickfix List',
    })
    vim.keymap.set('n', '<leader>xr', '<cmd>TroubleToggle lsp_references<cr>', {
      desc = 'LSP References',
    })
  end,
}
