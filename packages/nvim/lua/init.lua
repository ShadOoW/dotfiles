-- Main Lua init
-- Load options first (especially vim.g.mapleader)
require('config.options')
require('config.autocmds')
require('config.commands')
require('config.keymaps')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({'git', 'clone', '--filter=blob:none', '--branch=stable', -- latest stable release
    'https://github.com/folke/lazy.nvim.git', lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
-- The `spec` is a list of plugin specifications.
-- Plugins can be defined directly here or imported from other files/directories.
-- We will import all plugins from the 'plugins' directory.
-- Other configurations like autocmds, keymaps can also be loaded as modules by lazy.
require('lazy').setup({
    spec = { -- Import all plugin configurations from lua/plugins/init.lua
    {
        import = 'plugins'
    } -- Import local configurations as if they were plugins.
    -- This allows lazy.nvim to manage them if needed, or simply load them.
    -- These should return a table, even if it's empty, or just be a string
    -- if they are simple modules that do their work upon require.
    -- config.autocmds, config.commands, config.keymaps are now loaded above directly.
    },
    defaults = {
        lazy = false -- By default, load plugins on startup
    },
    install = {
        colorscheme = {'tokyonight'} -- Assuming tokyonight is your theme
        -- Missing plugins will be installed automatically.
    },
    performance = {
        rtp = {
            disabled_plugins = {'gzip', 'matchit', 'matchparen', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor',
                                'zipPlugin'}
        }
    },
    change_detection = {
        notify = false -- Don't notify about changes, apply them automatically
    },
    ui = {
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤 '
        }
    }
})

-- Utility modules (can be required by any part of the config after this point if needed)
-- These were required at the top before, but it's generally fine to require them
-- where they are first needed, or ensure they are simple modules that don't depend
-- on plugin states.
-- For now, let's assume they are general utilities. If they cause issues by being
-- loaded here, we can move their require calls into specific files that need them.
require('utils.keymap')
require('utils.file')
require('utils.string')
require('utils.reload').setup() -- Setup the config reload command

-- LSP setup was here before. It's better to handle LSP setup as part of
-- an lsp plugin configuration (e.g., in lua/plugins/lsp.lua or similar)
-- require('lsp.handlers')
-- require('lsp.setup')
--
-- The theme should be applied by the theme plugin's config function.
-- vim.cmd.colorscheme("tokyonight-night") -- This will be handled by the tokyonight plugin config.

-- Print a message to confirm this file was loaded (for debugging)
print('Neovim configuration loaded from lua/init.lua')
