-- Main Neovim configuration entry point
-- This file is the entry point that Neovim loads first
-- All actual configuration is handled in lua/init.lua
-- Bootstrap the main configuration
-- Since this file is in the config directory, Neovim automatically
-- includes the lua/ subdirectory in the runtime path
-- No need to manually add it to rtp or create circular references
-- Simply require the main lua configuration
require('config.options') -- Load options first (especially vim.g.mapleader)
require('config.autocmds')
require('config.commands')
require('config.keymaps')
require('config.cursor').setup()

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable', -- latest stable release
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with plugins
require('lazy').setup({
  spec = {
    {
      import = 'plugins',
    }, -- Import all plugin configurations
  },
  defaults = {
    lazy = false, -- Load plugins on startup
  },
  install = {
    colorscheme = { 'tokyonight' },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  change_detection = {
    notify = false,
  },
  ui = {
    icons = vim.g.have_nerd_font and {} or {},
  },
})

-- Load utility modules
require('utils.keymap')
require('utils.file')
require('utils.string')
require('utils.reload')
require('utils.tmux').setup()
