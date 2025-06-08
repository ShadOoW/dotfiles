-- Enhanced session management for tmux workflows
return { -- Auto-session management
  {
    'rmagatti/auto-session',
    lazy = false,
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('auto-session').setup({
        log_level = 'error',

        -- Session options
        auto_session_suppress_dirs = {
          '~/',
          '~/Downloads',
          '~/Documents',
          '~/Desktop',
          '/tmp',
          '/opt',
          '/usr',
          '/var',
        },

        -- Auto-save session when leaving Neovim
        auto_save_enabled = true,
        auto_restore_enabled = true,

        -- Use cwd as session name
        auto_session_use_git_branch = true,
        auto_session_create_enabled = function()
          -- Only create sessions in project directories
          local cwd = vim.fn.getcwd()
          return vim.fn.isdirectory(cwd .. '/.git') == 1
            or vim.fn.filereadable(cwd .. '/package.json') == 1
            or vim.fn.filereadable(cwd .. '/Cargo.toml') == 1
            or vim.fn.filereadable(cwd .. '/pyproject.toml') == 1
            or vim.fn.filereadable(cwd .. '/go.mod') == 1
        end,

        -- Pre and post hooks for session management
        pre_save_cmds = { 'lua vim.notify("Saving session...")' },
        post_restore_cmds = { 'lua vim.notify("Session restored!")' },

        -- Session lens for telescope integration
        session_lens = {
          -- Enable telescope integration
          buftypes_to_ignore = {},
          load_on_setup = true,
          theme_conf = {
            border = true,
          },
          previewer = false,
        },

        -- Bypass session save/restore for specific file types
        bypass_session_save_file_types = {
          'alpha',
          'dashboard',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'Trouble',
          'trouble',
        },
      })

      -- Set up keymaps for session management
      local keymap = vim.keymap.set
      keymap('n', '<leader>Ss', '<cmd>SessionSave<cr>', {
        desc = 'Save session',
      })
      keymap('n', '<leader>Sr', '<cmd>SessionRestore<cr>', {
        desc = 'Restore session',
      })
      keymap('n', '<leader>Sd', '<cmd>SessionDelete<cr>', {
        desc = 'Delete session',
      })
      keymap('n', '<leader>Sf', '<cmd>Telescope session-lens search_session<cr>', {
        desc = 'Find session',
      })
      keymap('n', '<leader>SP', '<cmd>SessionPurgeOrphaned<cr>', {
        desc = 'Purge orphaned sessions',
      })

      -- Auto-command for tmux integration
      vim.api.nvim_create_autocmd('User', {
        pattern = 'AutoSessionLoadPost',
        callback = function()
          -- Restore tmux window name if available
          local session_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
          if vim.env.TMUX then vim.fn.system('tmux rename-window "' .. session_name .. '"') end
        end,
      })
    end,
  }, -- Project-based session management
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup({
        -- Manual mode doesn't automatically change your root directory, so you have
        -- the option to manually do so using `:ProjectRoot` command.
        manual_mode = false,

        -- Methods of detecting the root directory
        detection_methods = { 'lsp', 'pattern' },

        -- All the patterns used to detect root dir, when **detection_methods** includes `pattern`
        patterns = {
          '.git',
          '_darcs',
          '.hg',
          '.bzr',
          '.svn',
          'Makefile',
          'package.json',
          'pyproject.toml',
          'Cargo.toml',
        },

        -- Table of lsp clients to ignore by name
        ignore_lsp = {},

        -- Don't calculate root dir on specific directories
        exclude_dirs = {},

        -- Show hidden files in telescope
        show_hidden = false,

        -- When set to false, you will get a message when project.nvim changes your directory.
        silent_chdir = true,

        -- What scope to change the directory, valid options are
        -- * global (default)
        -- * tab
        -- * win
        scope_chdir = 'global',

        -- Path where project.nvim will store the project history for use in telescope
        datapath = vim.fn.stdpath('data'),
      })
    end,
  }, -- Persisted.nvim for even better session management
  {
    'olimorris/persisted.nvim',
    lazy = false,
    config = function()
      require('persisted').setup({
        save_dir = vim.fn.expand(vim.fn.stdpath('data') .. '/sessions/'),
        silent = false,
        use_git_branch = true,
        default_branch = 'main',
        autosave = true,
        autoload = false, -- Let auto-session handle the loading

        -- Function to determine if a session should be saved
        should_autosave = function()
          -- Don't save session if we're in a non-project directory
          local cwd = vim.fn.getcwd()
          return vim.fn.isdirectory(cwd .. '/.git') == 1
            or vim.fn.filereadable(cwd .. '/package.json') == 1
            or vim.fn.filereadable(cwd .. '/Cargo.toml') == 1
            or vim.fn.filereadable(cwd .. '/pyproject.toml') == 1
            or vim.fn.filereadable(cwd .. '/go.mod') == 1
            or vim.fn.filereadable(cwd .. '/gradle.properties') == 1
            or vim.fn.filereadable(cwd .. '/pom.xml') == 1
        end,

        -- Telescope integration
        telescope = {
          reset_prompt_after_deletion = true,
        },
      })

      -- Additional keymaps for persisted
      vim.keymap.set('n', '<leader>St', '<cmd>Telescope persisted<cr>', {
        desc = 'Telescope sessions',
      })
      vim.keymap.set('n', '<leader>Sl', '<cmd>SessionLoad<cr>', {
        desc = 'Load session',
      })
      vim.keymap.set('n', '<leader>SS', '<cmd>SessionSave<cr>', {
        desc = 'Save session',
      })
      vim.keymap.set('n', '<leader>Sx', '<cmd>SessionDelete<cr>', {
        desc = 'Delete session',
      })
    end,
  },
}
