-- Enhanced Lua development for Neovim configuration (modern replacement for neodev)
return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = { -- Load luv types when the `vim.uv` word is found
      {
        path = '${3rd}/luv/library',
        words = { 'vim%.uv' },
      }, -- Load luvit types when the `vim.loop` word is found
      {
        path = '${3rd}/luv/library',
        words = { 'vim%.loop' },
      }, -- Load the wezterm types when the `wezterm` module is required
      {
        path = 'wezterm-types',
        mods = { 'wezterm' },
      }, -- Always load the LazyVim library
      'lazy.nvim',
    },
    -- always enable unless `vim.g.lazydev_enabled = false`
    -- This is the default
    enabled = function(root_dir)
      -- Enable for dotfiles nvim configuration
      if root_dir:find('/dotfiles/packages/nvim', 1, true) then return true end
      -- Enable for any lua project
      return vim.g.lazydev_enabled ~= false and vim.uv.fs_stat(root_dir .. '/.luarc.json')
    end,
    -- Enable completion for require statements and module annotations
    ---@type lspconfig.options.lua_ls
    lspconfig = {
      -- mason=false if you don't want mason to auto-install the server
      mason = true,
      settings = {
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { 'vim', 'require' },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
              [vim.fn.stdpath('data') .. '/lazy/lazy.nvim/lua/lazy'] = true,
            },
            maxPreload = 100000,
            preloadFileSize = 10000,
          },
          completion = {
            callSnippet = 'Replace',
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          },
        },
      },
    },
  },
}
