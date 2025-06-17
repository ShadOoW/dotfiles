-- Nvim-navic - Simple breadcrumbs for Neovim
return {
  'SmiteshP/nvim-navic',
  dependencies = { 'neovim/nvim-lspconfig' },
  config = function()
    require('nvim-navic').setup({
      icons = {
        File = '󰈙 ',
        Module = ' ',
        Namespace = '󰌗 ',
        Package = ' ',
        Class = '󰌗 ',
        Method = '󰆧 ',
        Property = ' ',
        Field = ' ',
        Constructor = ' ',
        Enum = '󰕘 ',
        Interface = '󰕘 ',
        Function = '󰊕 ',
        Variable = '󰆧 ',
        Constant = '󰏿 ',
        String = '󰀬 ',
        Number = '󰎠 ',
        Boolean = '◩ ',
        Array = '󰅪 ',
        Object = '󰅩 ',
        Key = '󰌋 ',
        Null = '󰟢 ',
        EnumMember = ' ',
        Struct = '󰌗 ',
        Event = ' ',
        Operator = '󰆕 ',
        TypeParameter = '󰊄 ',
      },
      lsp = {
        auto_attach = true,
        preference = nil,
      },
      highlight = true,
      separator = ' > ',
      depth_limit = 0,
      depth_limit_indicator = '..',
      safe_output = true,
      lazy_update_context = false,
      click = false,
      format_text = function(text) return text end,
    })

    -- Attach to LSP for automatic breadcrumb updates
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('NavicLspAttach', {
        clear = true,
      }),
      callback = function(args)
        local buffer = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(client, buffer)
        end
      end,
    })

    -- Custom highlight groups to match theme
    vim.schedule(function()
      vim.api.nvim_set_hl(0, 'NavicIconsFile', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsModule', {
        fg = '#fab387',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsNamespace', {
        fg = '#f9e2af',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsPackage', {
        fg = '#94e2d5',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsClass', {
        fg = '#f9e2af',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsMethod', {
        fg = '#cba6f7',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsProperty', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsField', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsConstructor', {
        fg = '#fab387',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsEnum', {
        fg = '#f9e2af',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsInterface', {
        fg = '#f9e2af',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsFunction', {
        fg = '#cba6f7',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsVariable', {
        fg = '#94e2d5',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsConstant', {
        fg = '#f38ba8',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsString', {
        fg = '#a6e3a1',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsNumber', {
        fg = '#fab387',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsBoolean', {
        fg = '#fab387',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsArray', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsObject', {
        fg = '#89b4fa',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsKey', {
        fg = '#cba6f7',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsNull', {
        fg = '#6c7086',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsEnumMember', {
        fg = '#94e2d5',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsStruct', {
        fg = '#f9e2af',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsEvent', {
        fg = '#f38ba8',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsOperator', {
        fg = '#89dceb',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicIconsTypeParameter', {
        fg = '#a6e3a1',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicText', {
        fg = '#cdd6f4',
        bg = 'NONE',
      })
      vim.api.nvim_set_hl(0, 'NavicSeparator', {
        fg = '#6c7086',
        bg = 'NONE',
      })
    end)
  end,
}
