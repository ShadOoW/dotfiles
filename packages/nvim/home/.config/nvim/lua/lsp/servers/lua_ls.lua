-- Lua LSP configuration
return {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global and other common globals
        globals = { 'vim', 'describe', 'it', 'before_each', 'after_each', 'pending', 'teardown', 'setup' },
        -- Disable certain annoying diagnostics
        disable = { 'missing-fields', 'incomplete-signature-doc' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          vim.env.VIMRUNTIME, -- Add the lazy.nvim path for plugin development
          '${3rd}/luv/library',
          '${3rd}/busted/library',
        },
        checkThirdParty = false,
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      -- Do not send telemetry data
      telemetry = {
        enable = false,
      },
      completion = {
        callSnippet = 'Replace',
      },
      hint = {
        enable = true,
        arrayIndex = 'Disable',
        await = true,
        paramName = 'Disable',
        paramType = false,
        semicolon = 'Disable',
        setType = false,
      },
    },
  },
}
