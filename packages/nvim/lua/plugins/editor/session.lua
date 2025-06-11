-- Modern Neovim Session Management
-- Uses persistence.nvim for robust, directory-based session persistence
return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {
    -- Session storage directory (XDG compliant)
    dir = vim.fn.expand(vim.fn.stdpath('data') .. '/sessions/'),

    -- Session options to save/restore
    options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' },

    -- Clean up before saving session
    pre_save = function()
      -- Close all floating windows
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' then vim.api.nvim_win_close(win, false) end
      end

      -- Close help buffers and other problematic buffer types
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
        local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')

        if
          buftype == 'help'
          or buftype == 'quickfix'
          or buftype == 'terminal'
          or filetype == 'trouble'
          or filetype == 'Trouble'
          or filetype == 'neo-tree'
          or filetype == 'dashboard'
        then
          pcall(vim.api.nvim_buf_delete, buf, {
            force = true,
          })
        end
      end
    end,

    -- Callback after loading session
    post_open = function()
      -- Refresh file tree if it exists
      if vim.fn.exists(':Neotree') == 2 then vim.cmd('Neotree filesystem reveal') end

      -- Restore cursor position and folds
      vim.cmd('normal! g`"')
      vim.cmd('silent! loadview')
    end,
  },

  -- Key mappings for session management
  keys = {
    {
      '<leader>Sr',
      function() require('persistence').load() end,
      desc = 'Restore session for current directory',
    },
    {
      '<leader>Sl',
      function()
        require('persistence').load({
          last = true,
        })
      end,
      desc = 'Load last session',
    },
    {
      '<leader>Ss',
      function() require('persistence').save() end,
      desc = 'Save current session',
    },
    {
      '<leader>Sd',
      function() require('persistence').stop() end,
      desc = 'Stop session persistence',
    },
  },

  init = function()
    -- Auto-restore session when starting nvim without file arguments
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        -- Only restore if no files were opened and we're in a directory with a session
        if vim.fn.argc() == 0 and not vim.g.started_by_dashboard then require('persistence').load() end
      end,
      nested = true,
    })

    -- Auto-save session on exit
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        -- Only save if we have buffers and we're not exiting due to error
        if #vim.api.nvim_list_bufs() > 1 and vim.v.dying == 0 then require('persistence').save() end
      end,
    })
  end,
}
