-- Neogit - Modern Git Interface
-- Works alongside fugitive for comprehensive git workflow
return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - for enhanced diff views
  },
  cmd = 'Neogit',
  keys = {
    {
      '<leader>gn',
      '<cmd>Neogit<cr>',
      desc = 'Open Neogit',
    },
    {
      '<leader>gc',
      '<cmd>Neogit commit<cr>',
      desc = 'Neogit commit',
    },
    {
      '<leader>gp',
      '<cmd>Neogit push<cr>',
      desc = 'Neogit push',
    },
    {
      '<leader>gl',
      '<cmd>Neogit pull<cr>',
      desc = 'Neogit pull',
    },
  },
  config = function()
    local neogit = require('neogit')

    neogit.setup({
      -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
      -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you have changed the repository.
      auto_refresh = true,

      -- Disable line highlighting in the buffer
      disable_line_highlighting = false,

      -- Value used for `--graph` when running `git log`
      graph_style = 'ascii',

      -- Changes what mode the Commit Editor starts in. `true` will leave nvim in normal mode, `false` will change nvim to
      -- insert mode, and `"auto"` will change nvim to insert mode IF the commit message is empty, otherwise leaving it in
      -- normal mode.
      disable_insert_on_commit = 'auto',

      -- When enabled, will watch the `.git/` directory for changes and refresh the status buffer in response to filesystem
      -- events.
      filewatcher = {
        interval = 1000,
        enabled = true,
      },

      -- Used to generate URL's for branch popup action "pull request".
      git_services = {
        ['github.com'] = 'https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1',
        ['bitbucket.org'] = 'https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1',
        ['gitlab.com'] = 'https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}',
      },

      -- Allows a different telescope sorter. Defaults to 'fuzzy_with_index_bias'
      telescope_sorter = function() return require('telescope').extensions.fzf.native_fzf_sorter() end,

      -- Persist the values of switches/options within and across sessions
      remember_settings = true,

      -- Scope persisted settings on a per-project basis
      use_per_project_settings = true,

      -- Table of settings to never persist
      ignored_settings = {
        'NeogitPushPopup--force-with-lease',
        'NeogitPushPopup--force',
        'NeogitPullPopup--rebase',
        'NeogitCommitPopup--allow-empty',
        'NeogitRevertPopup--no-edit',
      },

      -- Configure highlight group features
      highlight = {
        italic = true,
        bold = true,
        underline = true,
      },

      -- Set to false if you want to be responsible for creating _ALL_ keymappings
      use_default_keymaps = true,

      -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
      -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you have changed the repository.
      auto_show_console = true,

      -- Automatically show console if a command takes more than this many milliseconds
      auto_show_console_timeout = 2000,

      notification_icon = '󰊢',

      -- Customize displayed signs
      signs = {
        -- { CLOSED, OPENED }
        hunk = { '', '' },
        item = { '', '' },
        section = { '', '' },
      },

      -- Each Integration is auto-detected through plugin presence, however, it can be disabled by setting to `false`
      integrations = {
        -- If enabled, use telescope for menu selection rather than vim.ui.select.
        -- Allows multi-select and some things that vim.ui.select doesn't.
        telescope = true,
        diffview = true,

        -- Integration with fzf-lua
        fzf_lua = false,
      },

      sections = {
        -- Reverting/Cherry Picking
        sequencer = {
          folded = false,
          hidden = false,
        },
        untracked = {
          folded = false,
        },
        unstaged = {
          folded = false,
        },
        staged = {
          folded = false,
        },
        stashes = {
          folded = true,
        },
        unpulled = {
          folded = true,
        },
        unmerged = {
          folded = false,
        },
        unpulled_pushRemote = {
          folded = true,
          hidden = false,
        },
        unmerged_pushRemote = {
          folded = false,
          hidden = false,
        },
        recent = {
          folded = true,
        },
        rebase = {
          folded = true,
          hidden = false,
        },
      },

      mappings = {
        -- modify status buffer mappings
        status = {
          -- Removes the default mapping of "s" (use false instead of empty string)
          ['s'] = false,
          -- Add custom mappings if needed
          -- ['B'] = 'ShowRefs', -- Example of valid mapping
          ['<tab>'] = 'toggle_fold',
          ['<space>'] = 'stage_unstage',
          ['<cr>'] = 'commit',
          ['q'] = 'close',
        },
      },
    })

    -- Integration with existing git workflow
    -- Create a command to open neogit in current directory
    vim.api.nvim_create_user_command('G', function(opts)
      if opts.args == '' then
        neogit.open()
      else
        -- Pass through to fugitive for specific git commands
        vim.cmd('Git ' .. opts.args)
      end
    end, {
      nargs = '*',
      desc = 'Open Neogit or run Git command',
    })
  end,
}
