-- Standalone IntelliJ-like commands - ensures commands are always available
return {
  'nvim-lua/plenary.nvim', -- Minimal dependency
  lazy = false, -- Load immediately
  priority = 1000, -- High priority - load before other plugins
  config = function()
    -- Simple workspace analysis fallback
    local function simple_workspace_analysis()
      local project_root = vim.fn.getcwd()

      -- Show progress
      vim.notify('Starting workspace analysis...', vim.log.levels.INFO, {
        title = 'IntelliJ Diagnostics',
      })

      -- Try TypeScript analysis
      local has_tsconfig = vim.fn.filereadable(project_root .. '/tsconfig.json') == 1
      if has_tsconfig then
        vim.fn.jobstart({ 'npx', 'tsc', '--noEmit' }, {
          cwd = project_root,
          on_exit = function(_, code)
            if code == 0 then
              vim.notify('TypeScript: No errors found', vim.log.levels.INFO)
            else
              vim.notify('TypeScript: Found errors (check :checkhealth)', vim.log.levels.WARN)
            end
          end,
        })
      end

      -- Try ESLint analysis
      local eslint_configs = { '.eslintrc.js', '.eslintrc.json', '.eslintrc.yml' }
      local has_eslint = false
      for _, config in ipairs(eslint_configs) do
        if vim.fn.filereadable(project_root .. '/' .. config) == 1 then
          has_eslint = true
          break
        end
      end

      if has_eslint then
        vim.fn.jobstart({ 'npx', 'eslint', '.' }, {
          cwd = project_root,
          on_exit = function(_, code)
            if code == 0 then
              vim.notify('ESLint: No errors found', vim.log.levels.INFO)
            else
              vim.notify('ESLint: Found errors (check output)', vim.log.levels.WARN)
            end
          end,
        })
      end

      -- Refresh LSP diagnostics
      vim.diagnostic.reset()

      -- Request diagnostics from all LSP clients
      for _, client in ipairs(vim.lsp.get_clients()) do
        if client.supports_method('textDocument/diagnostic') then
          vim.lsp.buf_request(0, 'textDocument/diagnostic', {
            textDocument = vim.lsp.util.make_text_document_params(),
          })
        end
      end

      vim.defer_fn(function() vim.notify('Basic workspace analysis complete', vim.log.levels.INFO) end, 2000)
    end

    -- Simple problems view opener
    local function open_problems_view()
      -- Open trouble with diagnostics view
      local ok_trouble, trouble = pcall(require, 'trouble')
      if ok_trouble then
        trouble.open('diagnostics')
        vim.notify('Opened problems view', vim.log.levels.INFO)
      else
        -- Fallback to quickfix if trouble not available
        vim.diagnostic.setqflist()
        vim.cmd('copen')
        vim.notify('Opened quickfix list (trouble not available)', vim.log.levels.WARN)
      end
    end

    -- Simple diagnostic cleaner
    local function clear_all_diagnostics()
      -- Clear all diagnostic namespaces
      local namespaces = {
        'intellij_lsp',
        'intellij_tsc',
        'intellij_eslint',
        'intellij_cargo',
        'intellij_mypy',
        'intellij_lint',
      }

      for _, ns_name in ipairs(namespaces) do
        local ns = vim.api.nvim_create_namespace(ns_name)
        vim.diagnostic.reset(ns)
      end

      -- Clear quickfix and location lists
      vim.fn.setqflist({})
      vim.fn.setloclist(0, {})

      vim.notify('All diagnostics cleared', vim.log.levels.INFO)
    end

    -- Always create these commands (will override if main plugin loads)
    vim.api.nvim_create_user_command('IntellijAnalyze', simple_workspace_analysis, {
      desc = 'IntelliJ-like workspace analysis (basic version)',
    })

    vim.api.nvim_create_user_command('IntellijQuickFix', open_problems_view, {
      desc = 'Open IntelliJ-like problems view',
    })

    vim.api.nvim_create_user_command('IntellijClearDiagnostics', clear_all_diagnostics, {
      desc = 'Clear all diagnostics',
    })

    -- Additional helpful commands
    vim.api.nvim_create_user_command('IntellijTypeCheck', function()
      local project_root = vim.fn.getcwd()
      if vim.fn.filereadable(project_root .. '/tsconfig.json') == 1 then
        vim.cmd('!npx tsc --noEmit')
      else
        vim.notify('No tsconfig.json found in project root', vim.log.levels.WARN)
      end
    end, {
      desc = 'Run TypeScript type check',
    })

    vim.api.nvim_create_user_command('IntellijLint', function()
      local project_root = vim.fn.getcwd()
      local eslint_configs = { '.eslintrc.js', '.eslintrc.json', '.eslintrc.yml' }
      local has_eslint = false

      for _, config in ipairs(eslint_configs) do
        if vim.fn.filereadable(project_root .. '/' .. config) == 1 then
          has_eslint = true
          break
        end
      end

      if has_eslint then
        vim.cmd('!npx eslint .')
      else
        vim.notify('No ESLint config found in project root', vim.log.levels.WARN)
      end
    end, {
      desc = 'Run ESLint',
    })

    -- Auto-completion for commands
    vim.api.nvim_create_user_command('IntellijRefresh', function()
      -- Refresh all LSP clients
      for _, client in ipairs(vim.lsp.get_clients()) do
        if client.supports_method('workspace/didChangeConfiguration') then
          client.notify('workspace/didChangeConfiguration', {
            settings = client.config.settings,
          })
        end
      end

      -- Refresh diagnostics
      vim.diagnostic.reset()

      -- Request diagnostics from all LSP clients
      for _, client in ipairs(vim.lsp.get_clients()) do
        if client.supports_method('textDocument/diagnostic') then
          vim.lsp.buf_request(0, 'textDocument/diagnostic', {
            textDocument = vim.lsp.util.make_text_document_params(),
          })
        end
      end

      vim.notify('Refreshed LSP clients and diagnostics', vim.log.levels.INFO)
    end, {
      desc = 'Refresh LSP and diagnostics',
    })

    -- Status check command
    vim.api.nvim_create_user_command('IntellijStatus', function()
      local project_root = vim.fn.getcwd()
      local status = { 'IntelliJ Diagnostics Status:', '' }

      -- Check for configuration files
      local configs = {
        {
          file = 'tsconfig.json',
          desc = 'TypeScript',
        },
        {
          file = '.eslintrc.js',
          desc = 'ESLint (JS)',
        },
        {
          file = '.eslintrc.json',
          desc = 'ESLint (JSON)',
        },
        {
          file = 'package.json',
          desc = 'Node.js',
        },
        {
          file = 'Cargo.toml',
          desc = 'Rust',
        },
        {
          file = 'pyproject.toml',
          desc = 'Python',
        },
      }

      for _, config in ipairs(configs) do
        local exists = vim.fn.filereadable(project_root .. '/' .. config.file) == 1
        table.insert(
          status,
          string.format('  %s %s: %s', exists and '✓' or '✗', config.desc, exists and 'Found' or 'Not found')
        )
      end

      -- Check LSP clients
      table.insert(status, '')
      table.insert(status, 'Active LSP clients:')
      local clients = vim.lsp.get_clients()
      if #clients > 0 then
        for _, client in ipairs(clients) do
          table.insert(status, string.format('  • %s', client.name))
        end
      else
        table.insert(status, '  (none)')
      end

      -- Check trouble.nvim
      table.insert(status, '')
      local ok_trouble = pcall(require, 'trouble')
      table.insert(status, string.format('Trouble.nvim: %s', ok_trouble and 'Available' or 'Not available'))

      -- Check none-ls
      local ok_null_ls = pcall(require, 'null-ls')
      table.insert(status, string.format('None-ls: %s', ok_null_ls and 'Available' or 'Not available'))

      vim.notify(table.concat(status, '\n'), vim.log.levels.INFO, {
        title = 'IntelliJ Diagnostics',
      })
    end, {
      desc = 'Show IntelliJ diagnostics status',
    })
  end,
}
