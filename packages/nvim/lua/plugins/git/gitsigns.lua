return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local function map(mode, key, fn, desc)
        vim.keymap.set(mode, key, fn, { buffer = bufnr, desc = desc })
      end

      -- Hunk navigation (expr = true so diff-mode uses ]c/[c)
      vim.keymap.set('n', '<leader>gj', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, { buffer = bufnr, expr = true, desc = 'Next hunk' })

      vim.keymap.set('n', '<leader>gk', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, { buffer = bufnr, expr = true, desc = 'Previous hunk' })

      -- Stage / reset
      map({ 'n', 'v' }, '<leader>gs', gs.stage_hunk, 'Stage hunk')
      map('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
      map('n', '<leader>gu', gs.undo_stage_hunk, 'Undo stage hunk')
      map({ 'n', 'v' }, '<leader>gr', gs.reset_hunk, 'Reset hunk')
      map('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')

      -- Inspect
      map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
      map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame line')
      map('n', '<leader>gtb', gs.toggle_current_line_blame, 'Toggle line blame')
      map('n', '<leader>gtd', gs.toggle_deleted, 'Toggle deleted lines')

      -- Diff
      map('n', '<leader>gd', function() gs.diffthis() end, 'Diff hunk')
      map('n', '<leader>gD', function() gs.diffthis('~') end, 'Diff hunk against index')
    end,
  },
  config = function(_, opts)
    require('gitsigns').setup(opts)
  end,
}
