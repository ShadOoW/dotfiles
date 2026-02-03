return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require('lint')

    -- Configure markdownlint-cli2 as a custom linter
    lint.linters.markdownlint_cli2 = {
      cmd = 'markdownlint-cli2',
      stdin = true,
      args = { '--stdin' },
      stream = 'stderr',
      ignore_exitcode = true,
      parser = function(output)
        local items = {}
        for line in output:gmatch('[^\r\n]+') do
          -- Parse markdownlint-cli2 output format
          local file, line_num, col, rule, message = line:match('(.+):(%d+):?(%d*) ([%w-]+) (.+)')
          if file and line_num and rule and message then
            table.insert(items, {
              lnum = tonumber(line_num) - 1,
              col = col and tonumber(col) or 0,
              message = message,
              code = rule,
              severity = vim.diagnostic.severity.WARN,
              source = 'markdownlint-cli2',
            })
          end
        end
        return items
      end,
    }

    lint.linters_by_ft = {
      -- Documentation
      markdown = { 'markdownlint_cli2' },

      -- Web Development
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      css = { 'stylelint' },
      scss = { 'stylelint' },
      less = { 'stylelint' },
      html = { 'htmlhint' },
      json = { 'jsonlint' },
      yaml = { 'yamllint' },

      -- Programming Languages
      python = { 'ruff' },
      lua = { 'luacheck' },
      -- Rust: rust-analyzer (LSP) provides comprehensive diagnostics
      -- No separate linter needed as rust-analyzer handles all Rust diagnostics
      go = { 'golangcilint' },

      -- Shell
      bash = { 'shellcheck' },
      sh = { 'shellcheck' },
      zsh = { 'shellcheck' },

      -- Config and Infrastructure
      dockerfile = { 'hadolint' },
      sql = { 'sqlfluff' },

      -- Note: Odin uses OLS (Odin Language Server) for diagnostics
      -- No separate linter needed as OLS provides comprehensive diagnostics
    }

    -- Custom linter configurations
    lint.linters.luacheck.args = {
      '--globals',
      'vim',
      '--no-color',
      '--codes',
      '--ranges',
      '--formatter',
      'plain',
      '-',
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', {
      clear = true,
    })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        -- Skip linting for .env files to prevent ShellCheck warnings
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname:match('%.env$') or bufname:match('%.env%.') then return end

        if vim.bo.modifiable then lint.try_lint() end
      end,
    })
  end,
}
