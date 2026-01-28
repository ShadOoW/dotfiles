return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  dependencies = { 'williamboman/mason.nvim' },
  opts = {
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end

      -- Use LSP formatting for Odin files (OLS handles formatting with ols.json config)
      local filetype = vim.bo[bufnr].filetype
      if filetype == 'odin' then return {
        timeout_ms = 500,
        lsp_format = 'prefer',
      } end

      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters_by_ft = {
      -- Web Development - JavaScript/TypeScript (prettierd only)
      javascript = { 'prettierd' },
      javascriptreact = { 'prettierd' },
      typescript = { 'prettierd' },
      typescriptreact = { 'prettierd' },
      vue = { 'prettierd' },
      svelte = { 'prettierd' },

      -- Web Development - HTML/CSS (prettierd only)
      html = { 'prettierd' },
      css = { 'prettierd' },
      scss = { 'prettierd' },
      less = { 'prettierd' },

      -- Modern Web Frameworks (prettierd only)
      astro = { 'prettierd' },

      -- Data & Config (prettierd for supported formats)
      json = { 'prettierd' },
      jsonc = { 'prettierd' },
      json5 = { 'prettierd' },
      yaml = { 'prettierd' },
      yml = { 'prettierd' },
      toml = { 'taplo' },
      xml = { 'xmlformat', 'prettierd' },

      -- Documentation (prettierd only)
      -- markdown = { 'prettierd' },
      mdx = { 'prettierd' },

      -- Lua (stylua specialized)
      lua = { 'stylua' },

      -- Python (specialized formatters)
      python = { 'isort', 'black' },

      -- Shell (specialized formatter)
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      zsh = { 'shfmt' },

      -- Go (specialized formatters)
      go = { 'gofumpt', 'goimports' },

      -- Rust (use LSP formatting via rust-analyzer)
      rust = {},

      -- C/C++ (specialized formatter)
      c = { 'clang-format' },
      cpp = { 'clang-format' },

      -- SQL (specialized formatter)
      sql = { 'sql-formatter' },

      -- Docker (prettierd)
      dockerfile = { 'prettierd' },

      -- Odin (using LSP formatting via OLS with ols.json config)
      -- odin = {'odinfmt'}

      -- Dart/Flutter (using LSP formatting for best integration)
      dart = {}, -- Use LSP formatting (dartls handles this)
    },

    formatters = {
      -- Enhanced Prettier daemon for speed and consistency
      prettierd = {
        env = {
          PRETTIERD_DEFAULT_CONFIG = vim.fn.expand('~/.config/prettierd/.prettierrc.json'),
          -- Set NODE_PATH to include the node_modules from our custom prettier installation
          NODE_PATH = vim.fn.expand('~/.config/prettierd/node_modules'),
          -- Set PRETTIERD_LOCAL_PRETTIER_ONLY to use local prettier installation
          PRETTIERD_LOCAL_PRETTIER_ONLY = '1',
        },
        -- Specify the prettier module path for prettierd to use
        cwd = function() return vim.fn.expand('~/.config/prettierd') end,
      },

      -- Biome for fast JS/TS formatting (alternative to prettierd)
      biome = {
        command = 'biome',
        args = { 'format', '--stdin-file-path', '$FILENAME' },
        stdin = true,
      },

      -- Tailwind class sorting
      rustywind = {
        command = 'rustywind',
        args = { '--stdin' },
        stdin = true,
      },

      -- Enhanced stylua for Lua
      stylua = {
        prepend_args = {
          '--indent-type',
          'Spaces',
          '--indent-width',
          '2',
          '--quote-style',
          'ForceSingle',
          '--collapse-simple-statement',
          'Always',
          '--call-parentheses',
          'Always',
        },
        -- Add condition to check if stylua is available
        condition = function(self, ctx) return vim.fn.executable('stylua') == 1 end,
      },

      -- Shell formatting
      shfmt = {
        prepend_args = { '-i', '2', '-bn', '-ci', '-sr' },
      },

      -- Go formatting
      gofumpt = {
        command = 'gofumpt',
        args = { '-w', '$FILENAME' },
        stdin = false,
      },

      goimports = {
        command = 'goimports',
        args = { '-w', '$FILENAME' },
        stdin = false,
      },

      -- SQL formatting
      ['sql-formatter'] = {
        command = 'sql-formatter',
        args = { '--language', 'postgresql', '--tab-width', '2', '--keyword-case', 'upper' },
        stdin = true,
      },

      -- C/C++ formatting
      ['clang-format'] = {
        prepend_args = { '--style=Google' },
      },

      -- XML formatting
      xmlformat = {
        command = 'xmlformat',
        args = { '--indent', '2', '--preserve', 'literal' },
        stdin = true,
      },

      -- TOML formatting
      taplo = {
        command = 'taplo',
        args = { 'format', '-' },
        stdin = true,
      },


      -- Odin formatting (handled by OLS LSP server)
      -- odinfmt = {
      --     command = 'odinfmt',
      --     args = {'--stdin'},
      --     stdin = true,
      --     condition = function(self, ctx)
      --         return vim.fn.executable('odinfmt') == 1
      --     end
      -- }
    },

    -- Custom format options
    format_after_save = function(bufnr)
      -- Auto-sort Tailwind classes after save
      local ft = vim.bo[bufnr].filetype
      if
        vim.tbl_contains(
          { 'html', 'css', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'svelte', 'astro' },
          ft
        )
      then
        local conform = require('conform')
        conform.format({
          bufnr = bufnr,
          formatters = { 'rustywind' },
          quiet = true,
        })
      end
    end,
  },

  config = function(_, opts)
    local conform = require('conform')
    conform.setup(opts)

    -- Enhanced keymaps
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>ff',
      function()
        conform.format({
          async = true,
          lsp_format = 'fallback',
          timeout_ms = 2000,
        })
      end,
      {
        desc = 'Format file/range',
      }
    )

    -- Format with specific formatter
    vim.keymap.set({ 'n', 'v' }, '<leader>fF', function()
      local formatters = conform.list_formatters()
      if #formatters == 0 then
        require('utils.notify').warn('Conform', 'No formatters available for this buffer')
        return
      end

      local formatter_names = vim.tbl_map(function(f) return f.name end, formatters)
      vim.ui.select(formatter_names, {
        prompt = 'Select formatter:',
      }, function(choice)
        if choice then
          conform.format({
            formatters = { choice },
            async = true,
            timeout_ms = 2000,
          })
        end
      end)
    end, {
      desc = 'Format with specific formatter',
    })

    -- Toggle format on save
    vim.keymap.set('n', '<leader>tf', function()
      if vim.g.disable_autoformat or vim.b.disable_autoformat then
        vim.g.disable_autoformat = false
        vim.b.disable_autoformat = false
        require('utils.notify').success('Conform', 'Format on save enabled')
      else
        vim.g.disable_autoformat = true
        require('utils.notify').info('Conform', 'Format on save disabled')
      end
    end, {
      desc = 'Toggle format on save',
    })

    -- Command to show available formatters
    vim.api.nvim_create_user_command('ConformInfo', function()
      local formatters = conform.list_formatters()
      if #formatters == 0 then
        print('No formatters available for this buffer')
        return
      end

      print('Available formatters for ' .. vim.bo.filetype .. ':')
      for _, formatter in ipairs(formatters) do
        local status = formatter.available and '✓' or '✗'
        print(string.format('  %s %s', status, formatter.name))
      end
    end, {
      desc = 'Show available formatters',
    })
  end,
}
