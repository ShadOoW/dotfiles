-- IntelliJ IDEA-like diagnostics system with none-ls and real-time updates
return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'mfussenegger/nvim-lint',
    'folke/trouble.nvim',
    'nvimtools/none-ls-extras.nvim',
  },
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    -- Ensure required modules are available
    local ok_null_ls, null_ls = pcall(require, 'null-ls')
    if not ok_null_ls then
      vim.notify('null-ls not available', vim.log.levels.WARN)
      return
    end

    local ok_lint, lint = pcall(require, 'lint')
    if not ok_lint then vim.notify('nvim-lint not available', vim.log.levels.WARN) end

    -- Enhanced diagnostic functions
    local function refresh_problems_panel()
      local trouble = require('trouble')
      if trouble.is_open('diagnostics') then trouble.refresh('diagnostics') end
    end

    -- IntelliJ-like diagnostics configuration
    local intellij_diagnostics = {
      -- Real-time update settings
      realtime_updates = true,
      debounce_ms = 500,
      auto_refresh_trouble = true,
      auto_save_analysis = true,

      -- Workspace analysis settings
      workspace_analysis = {
        enabled = true,
        on_project_open = true,
        on_file_save = true,
        background_jobs = 6,
        file_patterns = {
          '*.ts',
          '*.tsx',
          '*.js',
          '*.jsx',
          '*.vue',
          '*.svelte',
          '*.py',
          '*.lua',
          '*.go',
          '*.rs',
          '*.java',
          '*.kt',
          '*.c',
          '*.cpp',
          '*.h',
          '*.hpp',
          '*.cs',
          '*.php',
        },
        exclude_dirs = {
          'node_modules',
          '.git',
          'dist',
          'build',
          'target',
          '.next',
          '.nuxt',
          'coverage',
          '__pycache__',
        },
      },

      -- UI settings for IntelliJ-like experience
      ui = {
        show_progress = true,
        auto_open_trouble = false, -- Open on errors only
        auto_close_trouble = true,
        floating_preview = true,
        severity_icons = {
          error = '󰅚',
          warning = '󰀪',
          info = '󰌶',
          hint = '󰌵',
        },
      },
    }

    -- Global diagnostic store for real-time updates
    local diagnostics_store = {
      lsp = {},
      external = {},
      lint = {},
    }

    -- Enhanced diagnostic namespace management
    local diagnostic_namespaces = {
      lsp = vim.api.nvim_create_namespace('intellij_lsp'),
      external_tsc = vim.api.nvim_create_namespace('intellij_tsc'),
      external_eslint = vim.api.nvim_create_namespace('intellij_eslint'),
      external_cargo = vim.api.nvim_create_namespace('intellij_cargo'),
      external_mypy = vim.api.nvim_create_namespace('intellij_mypy'),
      lint = vim.api.nvim_create_namespace('intellij_lint'),
    }

    -- Progress notification system
    local progress = {
      active_jobs = 0,
      total_files = 0,
      progress_handle = nil,
    }

    local function show_progress(message, percentage)
      if not intellij_diagnostics.ui.show_progress then return end

      if not progress.progress_handle then
        progress.progress_handle = vim.notify(message, vim.log.levels.INFO, {
          title = 'Project Analysis',
          timeout = false,
          hide_from_history = true,
        })
      else
        progress.progress_handle = vim.notify(message, vim.log.levels.INFO, {
          title = 'Project Analysis',
          timeout = false,
          hide_from_history = true,
          replace = progress.progress_handle,
        })
      end
    end

    local function hide_progress()
      if progress.progress_handle then
        vim.notify('Analysis complete', vim.log.levels.INFO, {
          title = 'Project Analysis',
          timeout = 3000,
          replace = progress.progress_handle,
        })
        progress.progress_handle = nil
      end
    end

    -- Enhanced file scanner for workspace analysis
    local function scan_workspace_files()
      local root_dir = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd()
      local files = {}

      local function should_include(path)
        -- Check file patterns
        for _, pattern in ipairs(intellij_diagnostics.workspace_analysis.file_patterns) do
          if vim.fn.fnamemodify(path, ':t'):match(vim.fn.glob2regpat(pattern)) then return true end
        end
        return false
      end

      local function is_excluded(path)
        for _, exclude in ipairs(intellij_diagnostics.workspace_analysis.exclude_dirs) do
          if path:find(exclude, 1, true) then return true end
        end
        return false
      end

      local function scan_recursive(dir)
        local handle = vim.loop.fs_scandir(dir)
        if not handle then return end

        while true do
          local name, type = vim.loop.fs_scandir_next(handle)
          if not name then break end

          local full_path = dir .. '/' .. name

          if type == 'directory' and not is_excluded(full_path) then
            scan_recursive(full_path)
          elseif type == 'file' and should_include(full_path) and not is_excluded(full_path) then
            table.insert(files, full_path)
          end
        end
      end

      scan_recursive(root_dir)
      return files
    end

    -- Real-time diagnostic updater
    local function update_diagnostics_store(source, bufnr, diagnostics)
      if not diagnostics_store[source] then diagnostics_store[source] = {} end

      diagnostics_store[source][bufnr] = diagnostics

      -- Auto-refresh Problems panel if enabled
      if intellij_diagnostics.auto_refresh_trouble then vim.schedule(function() refresh_problems_panel() end) end
    end

    -- Enhanced TypeScript workspace analysis
    local function run_typescript_analysis()
      local project_root = vim.fn.getcwd()
      local tsconfig = project_root .. '/tsconfig.json'

      if vim.fn.filereadable(tsconfig) == 0 then return end

      show_progress('Analyzing TypeScript...', 0)

      local Job = require('plenary.job')
      Job:new({
        command = 'npx',
        args = { 'tsc', '--noEmit', '--pretty', 'false' },
        cwd = project_root,
        on_exit = function(job, return_val)
          local output = job:result()
          local stderr = job:stderr_result()

          if stderr and #stderr > 0 then vim.list_extend(output, stderr) end

          local diagnostics_by_file = {}
          local error_count = 0

          for _, line in ipairs(output) do
            -- Enhanced TypeScript error parsing
            local file, row, col, severity, code, message = line:match('(.+)%((%d+),(%d+)%): (%w+) (TS%d+): (.+)')

            if file and row and col and message then
              local filepath = vim.fn.fnamemodify(project_root .. '/' .. file, ':p')

              if not diagnostics_by_file[filepath] then diagnostics_by_file[filepath] = {} end

              table.insert(diagnostics_by_file[filepath], {
                lnum = tonumber(row) - 1,
                col = tonumber(col) - 1,
                message = string.format('[%s] %s', code, message),
                severity = severity == 'error' and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
                source = 'tsc',
              })

              if severity == 'error' then error_count = error_count + 1 end
            end
          end

          -- Apply diagnostics to buffers
          for filepath, diags in pairs(diagnostics_by_file) do
            local buf = vim.fn.bufnr(filepath)
            if buf ~= -1 then
              vim.diagnostic.set(diagnostic_namespaces.external_tsc, buf, diags)
              update_diagnostics_store('external', buf, diags)
            end
          end

          progress.active_jobs = progress.active_jobs - 1
          if progress.active_jobs <= 0 then hide_progress() end

          if error_count > 0 then
            vim.notify(
              string.format('TypeScript analysis complete: %d errors found', error_count),
              vim.log.levels.WARN,
              {
                title = 'TypeScript Diagnostics',
              }
            )
          end
        end,
      }):start()

      progress.active_jobs = progress.active_jobs + 1
    end

    -- Enhanced ESLint workspace analysis
    local function run_eslint_analysis()
      local project_root = vim.fn.getcwd()
      local eslint_configs = { '.eslintrc.js', '.eslintrc.json', '.eslintrc.yml', '.eslintrc.yaml', 'eslint.config.js' }

      local has_eslint = false
      for _, config in ipairs(eslint_configs) do
        if vim.fn.filereadable(project_root .. '/' .. config) == 1 then
          has_eslint = true
          break
        end
      end

      if not has_eslint then return end

      show_progress('Running ESLint...', 0)

      local Job = require('plenary.job')
      Job
        :new({
          command = 'npx',
          args = { 'eslint', '.', '--format', 'json' },
          cwd = project_root,
          on_exit = function(job, return_val)
            local output = table.concat(job:result(), '\n')
            local diagnostics_by_file = {}

            if output ~= '' then
              local ok, results = pcall(vim.json.decode, output)
              if ok and type(results) == 'table' then
                for _, result in ipairs(results) do
                  if result.messages and #result.messages > 0 then
                    local filepath = result.filePath
                    diagnostics_by_file[filepath] = {}

                    for _, msg in ipairs(result.messages) do
                      table.insert(diagnostics_by_file[filepath], {
                        lnum = (msg.line or 1) - 1,
                        col = (msg.column or 1) - 1,
                        message = string.format('[%s] %s', msg.ruleId or 'eslint', msg.message),
                        severity = msg.severity == 2 and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
                        source = 'eslint',
                      })
                    end
                  end
                end
              end
            end

            -- Apply diagnostics to buffers
            for filepath, diags in pairs(diagnostics_by_file) do
              local buf = vim.fn.bufnr(filepath)
              if buf ~= -1 then
                vim.diagnostic.set(diagnostic_namespaces.external_eslint, buf, diags)
                update_diagnostics_store('external', buf, diags)
              end
            end

            progress.active_jobs = progress.active_jobs - 1
            if progress.active_jobs <= 0 then hide_progress() end
          end,
        })
        :start()

      progress.active_jobs = progress.active_jobs + 1
    end

    -- Background file analysis
    local function analyze_file_background(filepath)
      if not vim.fn.filereadable(filepath) then return end

      progress.active_jobs = progress.active_jobs + 1

      vim.defer_fn(function()
        -- Open file in hidden buffer for analysis
        vim.schedule(function()
          local buf = vim.fn.bufadd(filepath)
          if buf and vim.api.nvim_buf_is_valid(buf) then
            vim.fn.bufload(buf)

            -- Wait for LSP to process
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(buf) then
                local diagnostics = vim.diagnostic.get(buf)
                if #diagnostics > 0 then update_diagnostics_store('lsp', buf, diagnostics) end

                -- Clean up
                if vim.api.nvim_buf_is_valid(buf) then
                  vim.api.nvim_buf_delete(buf, {
                    force = true,
                  })
                end
              end

              progress.active_jobs = progress.active_jobs - 1
            end, 500)
          end
        end)
      end)
    end

    -- IntelliJ-like workspace analysis
    local function run_full_workspace_analysis()
      if not intellij_diagnostics.workspace_analysis.enabled then return end

      show_progress('Scanning workspace...', 0)

      local files = scan_workspace_files()
      progress.total_files = #files

      -- Run external tools
      run_typescript_analysis()
      run_eslint_analysis()

      -- Stagger file analysis to prevent overwhelming the system
      for i, filepath in ipairs(files) do
        vim.defer_fn(function() analyze_file_background(filepath) end, i * 50) -- 50ms delay between files
      end

      -- Set completion timer
      vim.defer_fn(function()
        if progress.active_jobs == 0 then
          hide_progress()
          vim.notify(string.format('Workspace analysis complete (%d files)', #files), vim.log.levels.INFO, {
            title = 'IntelliJ Diagnostics',
          })
        end
      end, 5000)
    end

    -- Debounced analysis function
    local debounce_timer = nil
    local function debounced_analysis()
      if debounce_timer then vim.fn.timer_stop(debounce_timer) end

      debounce_timer = vim.fn.timer_start(intellij_diagnostics.debounce_ms, function()
        run_typescript_analysis()
        run_eslint_analysis()
      end)
    end

    -- Setup null-ls with enhanced configuration
    null_ls.setup({
      sources = { -- TypeScript / JavaScript diagnostics using none-ls-extras
        require('none-ls.diagnostics.eslint').with({
          condition = function(utils)
            return utils.root_has_file({
              '.eslintrc.js',
              '.eslintrc.json',
              '.eslintrc.yml',
              '.eslintrc.yaml',
              'eslint.config.js',
            })
          end,
        }), -- Python
        null_ls.builtins.diagnostics.mypy.with({
          condition = function(utils) return utils.root_has_file({ 'mypy.ini', '.mypy.ini', 'pyproject.toml' }) end,
        }), -- Lua
        null_ls.builtins.diagnostics.selene.with({
          condition = function(utils) return utils.root_has_file({ 'selene.toml' }) end,
        }), -- Formatting sources
        null_ls.builtins.formatting.prettier.with({
          filetypes = { 'javascript', 'typescript', 'json', 'yaml', 'html', 'css' },
        }),
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black,
      },

      -- Enhanced on_attach for real-time updates
      on_attach = function(client, bufnr)
        if client.supports_method('textDocument/formatting') then
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                bufnr = bufnr,
              })
            end,
          })
        end
      end,
    })

    -- Commands for IntelliJ-like experience
    vim.api.nvim_create_user_command('IntellijAnalyze', run_full_workspace_analysis, {
      desc = 'Run full IntelliJ-like workspace analysis',
    })

    vim.api.nvim_create_user_command('IntellijQuickFix', function() require('trouble').open('diagnostics') end, {
      desc = 'Open IntelliJ-like problems view',
    })

    vim.api.nvim_create_user_command('IntellijClearDiagnostics', function()
      -- Clear all diagnostic namespaces
      for _, ns in pairs(diagnostic_namespaces) do
        vim.diagnostic.reset(ns)
      end

      -- Clear diagnostic store
      diagnostics_store = {
        lsp = {},
        external = {},
        lint = {},
      }
      vim.notify('All diagnostics cleared', vim.log.levels.INFO)
    end, {
      desc = 'Clear all diagnostics',
    })

    -- Setup reusable panel manager for diagnostics-specific keymaps
    local panel_manager = require('utils.panel-manager')

    -- Create separate trouble panel configurations for workspace and buffer diagnostics
    local diagnostics_trouble_panels = {
      workspace_diagnostics = {
        open = function(opts) require('trouble').open('diagnostics', opts or {}) end,
        toggle = function(opts) require('trouble').toggle('diagnostics', opts or {}) end,
        close = function() require('trouble').close('diagnostics') end,
        is_open = function() return require('trouble').is_open('diagnostics') end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
      buffer_diagnostics = {
        open = function(opts)
          local current_buf = vim.api.nvim_get_current_buf()
          local merged_opts = vim.tbl_deep_extend('force', {
            mode = 'diagnostics',
            filter = function(items)
              -- Filter diagnostics to only show those from the current buffer
              local filtered = {}
              for _, item in ipairs(items) do
                if item.buf == current_buf then table.insert(filtered, item) end
              end
              return filtered
            end,
          }, opts or {})
          require('trouble').open(merged_opts)
        end,
        toggle = function(opts)
          local current_buf = vim.api.nvim_get_current_buf()
          local merged_opts = vim.tbl_deep_extend('force', {
            mode = 'diagnostics',
            filter = function(items)
              -- Filter diagnostics to only show those from the current buffer
              local filtered = {}
              for _, item in ipairs(items) do
                if item.buf == current_buf then table.insert(filtered, item) end
              end
              return filtered
            end,
          }, opts or {})
          require('trouble').toggle(merged_opts)
        end,
        close = function() require('trouble').close('diagnostics') end,
        is_open = function() return require('trouble').is_open('diagnostics') end,
        global_var = 'current_trouble_mode',
        refresh_cmd = 'redrawstatus',
      },
    }

    -- Create exclusive panel manager for diagnostics
    local diagnostics_manager = panel_manager.create_exclusive_group('diagnostics_trouble', diagnostics_trouble_panels)

    -- Workspace and buffer diagnostic keymaps
    vim.keymap.set('n', '<leader>xw', diagnostics_manager.keymap('workspace_diagnostics'), {
      desc = 'Workspace problems',
    })

    vim.keymap.set('n', '<leader>xb', diagnostics_manager.keymap('buffer_diagnostics'), {
      desc = 'Buffer problems',
    })

    -- IntelliJ-style keymaps
    vim.keymap.set('n', '<leader>xA', '<cmd>IntellijAnalyze<cr>', {
      desc = 'IntelliJ: Analyze entire workspace',
    })
    vim.keymap.set('n', '<leader>xC', '<cmd>IntellijClearDiagnostics<cr>', {
      desc = 'IntelliJ: Clear all diagnostics',
    })

    -- Auto-analysis setup
    if intellij_diagnostics.workspace_analysis.on_project_open then
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function() vim.defer_fn(run_full_workspace_analysis, 2000) end,
        desc = 'Auto-analyze workspace on startup',
      })
    end

    if intellij_diagnostics.workspace_analysis.on_file_save then
      vim.api.nvim_create_autocmd('BufWritePost', {
        callback = debounced_analysis,
        desc = 'Auto-analyze on file save',
      })
    end

    -- Real-time LSP diagnostic updates
    vim.api.nvim_create_autocmd('DiagnosticChanged', {
      callback = function(args) update_diagnostics_store('lsp', args.buf, vim.diagnostic.get(args.buf)) end,
      desc = 'Update diagnostic store on LSP changes',
    })

    return intellij_diagnostics
  end,
}
