-- Standalone IntelliJ-like commands - ensures commands are always available
return {
  'nvim-lua/plenary.nvim', -- Minimal dependency
  lazy = false, -- Load immediately
  priority = 1000, -- High priority - load before other plugins
  config = function()
    local notify = require('utils.notify')

    -- Simple workspace analysis fallback
    local function simple_workspace_analysis()
      local project_root = vim.fn.getcwd()

      -- Show progress
      notify.info('Problems', 'Starting workspace analysis...')

      -- Try TypeScript analysis
      local has_tsconfig = vim.fn.filereadable(project_root .. '/tsconfig.json') == 1
      if has_tsconfig then
        vim.fn.jobstart({ 'npx', 'tsc', '--noEmit' }, {
          cwd = project_root,
          on_exit = function(_, code)
            if code == 0 then
              notify.success('TypeScript', 'No errors found')
            else
              notify.warn('TypeScript', 'Found errors (check :checkhealth)')
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
              notify.success('ESLint', 'No errors found')
            else
              notify.warn('ESLint', 'Found errors (check output)')
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

      vim.defer_fn(function() notify.info('Problems', 'Basic workspace analysis complete') end, 2000)
    end

    -- Simple problems view opener
    local function open_problems_view()
      -- Open trouble with diagnostics view
      local ok_trouble, trouble = pcall(require, 'trouble')
      if ok_trouble then
        trouble.open('diagnostics')
        notify.info('Problems', 'Opened problems view')
      else
        -- Fallback to quickfix if trouble not available
        vim.diagnostic.setqflist()
        vim.cmd('copen')
        notify.warn('Problems', 'Opened quickfix list (trouble not available)')
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

      notify.success('Problems', 'All diagnostics cleared')
    end

    -- Always create these commands (will override if main plugin loads)
    vim.api.nvim_create_user_command('IntellijAnalyze', simple_workspace_analysis, {
      desc = 'Workspace analysis (basic version)',
    })

    vim.api.nvim_create_user_command('IntellijQuickFix', open_problems_view, {
      desc = 'Open Problems view',
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
        notify.warn('TypeScript', 'No tsconfig.json found in project root')
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
        notify.warn('ESLint', 'No ESLint config found in project root')
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

      notify.success('Problems', 'Refreshed LSP clients and diagnostics')
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

      notify.info('Problems', table.concat(status, '\n'))
    end, {
      desc = 'Show diagnostics status',
    })
  end,
}
