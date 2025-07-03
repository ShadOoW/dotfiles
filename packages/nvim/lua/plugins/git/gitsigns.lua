-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.
return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = {
        text = '+',
      },
      change = {
        text = '~',
      },
      delete = {
        text = '_',
      },
      topdelete = {
        text = '‾',
      },
      changedelete = {
        text = '~',
      },
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      -- Navigation between hunks
      vim.keymap.set('n', '<leader>hj', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, {
        buffer = bufnr,
        expr = true,
        desc = 'Jump to next hunk',
      })

      vim.keymap.set('n', '<leader>hk', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, {
        buffer = bufnr,
        expr = true,
        desc = 'Jump to previous hunk',
      })

      -- Actions
      -- Stage hunk under cursor
      vim.keymap.set({ 'n', 'v' }, '<leader>hs', gs.stage_hunk, {
        buffer = bufnr,
        desc = 'Stage Hunk Under Cursor',
      })

      -- Stage entire buffer
      vim.keymap.set('n', '<leader>hS', function() gs.stage_buffer() end, {
        buffer = bufnr,
        desc = 'Stage Entire Buffer',
      })

      -- Undo last staged hunk
      vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, {
        buffer = bufnr,
        desc = 'Undo Stage Hunk',
      })

      -- Reset hunk under cursor
      vim.keymap.set({ 'n', 'v' }, '<leader>hr', gs.reset_hunk, {
        buffer = bufnr,
        desc = 'Reset Hunk Under Cursor',
      })

      -- Reset entire buffer
      vim.keymap.set('n', '<leader>hR', function() gs.reset_buffer() end, {
        buffer = bufnr,
        desc = 'Reset Entire Buffer',
      })

      -- Preview hunk inline
      vim.keymap.set('n', '<leader>hp', gs.preview_hunk, {
        buffer = bufnr,
        desc = 'Preview Hunk Under Cursor',
      })

      -- Blame line
      vim.keymap.set(
        'n',
        '<leader>hb',
        function()
          gs.blame_line({
            full = true,
          })
        end,
        {
          buffer = bufnr,
          desc = 'Blame Line',
        }
      )

      -- Toggle line blame
      vim.keymap.set('n', '<leader>htb', gs.toggle_current_line_blame, {
        buffer = bufnr,
        desc = 'Toggle Line Blame',
      })

      -- Toggle deleted lines
      vim.keymap.set('n', '<leader>htd', gs.toggle_deleted, {
        buffer = bufnr,
        desc = 'Toggle Deleted Lines',
      })

      -- Diff operations
      vim.keymap.set('n', '<leader>hd', function() gs.diffthis() end, {
        buffer = bufnr,
        desc = 'Diff Hunk Under Cursor',
      })

      vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, {
        buffer = bufnr,
        desc = 'Diff Hunk Under Cursor (against index)',
      })
    end,
  },
  config = function()
    -- Setup gitsigns first
    require('gitsigns').setup()
  end,
}
