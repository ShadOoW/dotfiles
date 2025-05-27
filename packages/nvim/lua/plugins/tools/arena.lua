-- arena.nvim: Persist and toggle multiple buffers with a single command
return {
  'dzfrias/arena.nvim',
  lazy = false, -- Needed to ensure commands are available
  opts = {
    -- Max number of buffers in the arena
    max_items = 50,
    always_context = {
      'mod.rs',
      'init.lua',
      'index.ts',
      'index.js',
    },
    ignore_current = false,
    devicons = true,

    -- Custom keybindings for the Arena window
    keybinds = {
      ['<CR>'] = function(arena) arena:open_file() end,
      ['d'] = function(arena) arena:delete_buffer() end,
      ['D'] = function(arena) arena:delete_unpinned() end,
      ['a'] = function(arena) arena:pin_buffer() end,
      ['v'] = function(arena) arena:vsplit() end,
      ['x'] = function(arena) arena:hsplit() end,
      ['t'] = function(arena) arena:tabnew() end,
    },

    -- How to filter items that will be shown in the arena
    filter = function(buf)
      -- Filter out unwanted buffer types
      local buftype = vim.bo[buf].buftype
      if buftype == 'terminal' or buftype == 'quickfix' or buftype == 'nofile' then return false end

      -- Keep all normal buffers
      local bufname = vim.api.nvim_buf_get_name(buf)
      return bufname ~= '' -- Filter out unnamed buffers
    end,

    -- Auto-save the arena to disk
    auto_save = true,
  },
  config = function(_, opts)
    require('arena').setup(opts)

    -- Add keymaps for Arena
    vim.keymap.set('n', '<leader><leader>', '<cmd>ArenaToggle<CR>', {
      desc = 'Toggle Arena buffer',
    })
    vim.keymap.set('n', '<leader>ap', '<cmd>ArenaPrev<CR>', {
      desc = 'Previous Arena buffer',
    })
    vim.keymap.set('n', '<leader>an', '<cmd>ArenaNext<CR>', {
      desc = 'Next Arena buffer',
    })
    vim.keymap.set('n', '<leader>ad', '<cmd>ArenaDelete<CR>', {
      desc = 'Delete from Arena',
    })
  end,
}
