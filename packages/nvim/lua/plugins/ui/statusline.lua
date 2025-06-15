-- Custom statusline with build status and project information
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'rcarriga/nvim-notify' },
  event = 'VeryLazy',
  config = function()
    local lualine = require('lualine')

    -- Custom components
    local function build_status()
      -- Check if there's an active build process
      local overseer_available, overseer = pcall(require, 'overseer')
      if overseer_available then
        local tasks = overseer.list_tasks({
          recent_first = true,
        })
        for _, task in ipairs(tasks) do
          if task.status == overseer.STATUS.RUNNING then
            if task.name:match('gradle') or task.name:match('build') or task.name:match('compile') then
              return '🔨 Building...'
            end
          elseif task.status == overseer.STATUS.SUCCESS then
            if task.name:match('gradle') or task.name:match('build') or task.name:match('compile') then
              return '✅ Build OK'
            end
          elseif task.status == overseer.STATUS.FAILURE then
            if task.name:match('gradle') or task.name:match('build') or task.name:match('compile') then
              return '❌ Build Failed'
            end
          end
        end
      end
      return ''
    end

    local function project_name()
      local cwd = vim.fn.getcwd()
      local project_name = vim.fn.fnamemodify(cwd, ':t')

      -- Check if it's a Gradle project
      if
        vim.fn.filereadable(cwd .. '/build.gradle') == 1
        or vim.fn.filereadable(cwd .. '/build.gradle.kts') == 1
        or vim.fn.filereadable(cwd .. '/settings.gradle') == 1
        or vim.fn.filereadable(cwd .. '/settings.gradle.kts') == 1
      then
        return '📦 ' .. project_name
      end

      -- Check if it's a Maven project
      if vim.fn.filereadable(cwd .. '/pom.xml') == 1 then return '📦 ' .. project_name end

      -- Check if it's a Node.js project
      if vim.fn.filereadable(cwd .. '/package.json') == 1 then return '📦 ' .. project_name end

      -- Check if it's a Rust project
      if vim.fn.filereadable(cwd .. '/Cargo.toml') == 1 then return '🦀 ' .. project_name end

      -- Check if it's a Python project
      if
        vim.fn.filereadable(cwd .. '/pyproject.toml') == 1
        or vim.fn.filereadable(cwd .. '/setup.py') == 1
        or vim.fn.filereadable(cwd .. '/requirements.txt') == 1
      then
        return '🐍 ' .. project_name
      end

      -- Check if it's a Git repository
      if vim.fn.isdirectory(cwd .. '/.git') == 1 then return '📁 ' .. project_name end

      return '📁 ' .. project_name
    end

    local function lsp_status()
      local clients = vim.lsp.get_clients({
        bufnr = 0,
      })
      if #clients == 0 then return '' end

      local client_names = {}
      for _, client in ipairs(clients) do
        table.insert(client_names, client.name)
      end

      return '🔧 ' .. table.concat(client_names, ', ')
    end

    local function dap_status()
      local dap_available, dap = pcall(require, 'dap')
      if not dap_available then return '' end

      local session = dap.session()
      if session then return '🐛 Debug Active' end
      return ''
    end

    local function test_status()
      local neotest_available, neotest = pcall(require, 'neotest')
      if not neotest_available then return '' end

      -- Get test results summary
      local summary = neotest.state.status_counts()
      if not summary then return '' end

      if summary.total and summary.total > 0 then
        if summary.failed and summary.failed > 0 then
          return '🧪 ' .. summary.failed .. '/' .. summary.total .. ' Failed'
        elseif summary.passed and summary.passed > 0 then
          return '🧪 ' .. summary.passed .. '/' .. summary.total .. ' Passed'
        else
          return '🧪 ' .. summary.total .. ' Tests'
        end
      end
      return ''
    end

    local function gutentags_status()
      if vim.g.gutentags_enabled == 1 then
        -- Check if gutentags is currently updating
        if vim.fn.exists('*gutentags#inprogress') == 1 and vim.fn['gutentags#inprogress']() == 1 then
          return '🏷️ Updating...'
        else
          return '🏷️ Tags Ready'
        end
      end
      return ''
    end

    local function java_version()
      if vim.bo.filetype == 'java' then
        -- Try to get Java version from JDTLS
        local clients = vim.lsp.get_clients({
          name = 'jdtls',
        })
        if #clients > 0 then return '☕ Java' end
      end
      return ''
    end

    -- Custom theme with modern colors
    local custom_theme = {
      normal = {
        a = {
          fg = '#1e1e2e',
          bg = '#89b4fa',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#313244',
        },
        c = {
          fg = '#bac2de',
          bg = '#1e1e2e',
        },
      },
      insert = {
        a = {
          fg = '#1e1e2e',
          bg = '#a6e3a1',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#313244',
        },
        c = {
          fg = '#bac2de',
          bg = '#1e1e2e',
        },
      },
      visual = {
        a = {
          fg = '#1e1e2e',
          bg = '#f9e2af',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#313244',
        },
        c = {
          fg = '#bac2de',
          bg = '#1e1e2e',
        },
      },
      replace = {
        a = {
          fg = '#1e1e2e',
          bg = '#f38ba8',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#313244',
        },
        c = {
          fg = '#bac2de',
          bg = '#1e1e2e',
        },
      },
      command = {
        a = {
          fg = '#1e1e2e',
          bg = '#cba6f7',
          gui = 'bold',
        },
        b = {
          fg = '#cdd6f4',
          bg = '#313244',
        },
        c = {
          fg = '#bac2de',
          bg = '#1e1e2e',
        },
      },
      inactive = {
        a = {
          fg = '#6c7086',
          bg = '#313244',
        },
        b = {
          fg = '#6c7086',
          bg = '#313244',
        },
        c = {
          fg = '#6c7086',
          bg = '#1e1e2e',
        },
      },
    }

    lualine.setup({
      options = {
        theme = custom_theme,
        component_separators = {
          left = '',
          right = '',
        },
        section_separators = {
          left = '',
          right = '',
        },
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str) return str:sub(1, 1) end,
          },
        },
        lualine_b = {
          {
            'branch',
            icon = '',
          },
          {
            'diff',
            symbols = {
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
          },
        },
        lualine_c = {
          {
            project_name,
            color = {
              fg = '#89b4fa',
              gui = 'bold',
            },
          },
          {
            'filename',
            path = 1,
            symbols = {
              modified = ' ●',
              readonly = ' ',
              unnamed = '[No Name]',
            },
          },
        },
        lualine_x = {
          {
            build_status,
            color = function()
              local status = build_status()
              if status:match('Building') then
                return {
                  fg = '#f9e2af',
                }
              elseif status:match('OK') then
                return {
                  fg = '#a6e3a1',
                }
              elseif status:match('Failed') then
                return {
                  fg = '#f38ba8',
                }
              end
              return {
                fg = '#cdd6f4',
              }
            end,
          },
          {
            test_status,
            color = function()
              local status = test_status()
              if status:match('Failed') then
                return {
                  fg = '#f38ba8',
                }
              elseif status:match('Passed') then
                return {
                  fg = '#a6e3a1',
                }
              end
              return {
                fg = '#cdd6f4',
              }
            end,
          },
          {
            dap_status,
            color = {
              fg = '#f9e2af',
            },
          },
          {
            gutentags_status,
            color = function()
              local status = gutentags_status()
              if status:match('Updating') then
                return {
                  fg = '#f9e2af',
                }
              else
                return {
                  fg = '#a6e3a1',
                }
              end
            end,
          },
          {
            java_version,
            color = {
              fg = '#fab387',
            },
          },
          {
            lsp_status,
            color = {
              fg = '#89b4fa',
            },
          },
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            symbols = {
              error = ' ',
              warn = ' ',
              info = ' ',
              hint = ' ',
            },
          },
        },
        lualine_y = {
          {
            'encoding',
            fmt = function(str) return str:upper() end,
          },
          'fileformat',
          'filetype',
        },
        lualine_z = { 'progress', 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { 'nvim-tree', 'toggleterm', 'quickfix', 'fugitive' },
    })

    -- Auto-refresh statusline when overseer tasks change
    local overseer_group = vim.api.nvim_create_augroup('StatuslineOverseer', {
      clear = true,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = { 'OverseerTaskUpdate', 'OverseerTaskComplete' },
      group = overseer_group,
      callback = function() vim.cmd('redrawstatus') end,
    })

    -- Auto-refresh when DAP status changes
    local dap_group = vim.api.nvim_create_augroup('StatuslineDAP', {
      clear = true,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = { 'DapSessionStarted', 'DapSessionStopped' },
      group = dap_group,
      callback = function() vim.cmd('redrawstatus') end,
    })

    -- Auto-refresh when LSP attaches/detaches
    local lsp_group = vim.api.nvim_create_augroup('StatuslineLSP', {
      clear = true,
    })
    vim.api.nvim_create_autocmd('LspAttach', {
      group = lsp_group,
      callback = function() vim.cmd('redrawstatus') end,
    })
    vim.api.nvim_create_autocmd('LspDetach', {
      group = lsp_group,
      callback = function() vim.cmd('redrawstatus') end,
    })
  end,
}
