-- yanky.nvim: Improved yank and put functionality
return {
  'gbprod/yanky.nvim',
  event = 'VeryLazy',
  config = function()
    -- Basic yanky setup without telescope-specific options
    require('yanky').setup({
      ring = {
        history_length = 100,
        storage = 'memory',
        sync_with_numbered_registers = true,
        cancel_event = 'update',
      },
      picker = {
        select = {
          action = nil, -- Use default action
        },
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    })

    -- Basic yanky mappings (these don't depend on telescope)
    vim.keymap.set({ 'n', 'x' }, 'y', '<Plug>(YankyYank)', {
      desc = 'Yank text',
    })

    -- Set buffer-local keymaps for p and P, excluding git buffers
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = '*',
      callback = function()
        if vim.bo.filetype ~= 'git' then
          vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)', {
            desc = 'Put after cursor',
            buffer = true,
          })
          vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)', {
            desc = 'Put before cursor',
            buffer = true,
          })
        end
      end,
    })
    vim.keymap.set('n', '<c-n>', '<Plug>(YankyCycleForward)', {
      desc = 'Cycle forward through yank history',
    })
    vim.keymap.set('n', '<c-p>', '<Plug>(YankyCycleBackward)', {
      desc = 'Cycle backward through yank history',
    })
  end,
}
