-- Enhanced statusline configuration
-- Provides modern, contextual status information with clean design
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'rcarriga/nvim-notify' },
  event = 'VeryLazy',
  config = function()
    local lualine = require('lualine')

    local function build_status()
      local overseer_available, overseer = pcall(require, 'overseer')
      if not overseer_available then return '' end

      local tasks = overseer.list_tasks({
        recent_first = true,
      })
      for _, task in ipairs(tasks) do
        if task.status == overseer.STATUS.RUNNING then
          return '🔨 Building...'
        elseif task.status == overseer.STATUS.SUCCESS then
          return '✅ Build OK'
        elseif task.status == overseer.STATUS.FAILURE then
          return '❌ Build Failed'
        end
      end
      return ''
    end

    local function get_project_name()
      local cwd = vim.fn.getcwd()
      local project_name = vim.fn.fnamemodify(cwd, ':t')

      -- Java projects with Gradle
      if vim.fn.filereadable(cwd .. '/build.gradle') == 1 or vim.fn.filereadable(cwd .. '/settings.gradle') == 1 then
        return ' ' .. project_name
      end

      -- Java projects with Maven
      if vim.fn.filereadable(cwd .. '/pom.xml') == 1 then return ' ' .. project_name end

      -- Node.js projects
      if vim.fn.filereadable(cwd .. '/package.json') == 1 then return ' ' .. project_name end

      -- Rust projects
      if vim.fn.filereadable(cwd .. '/Cargo.toml') == 1 then return ' ' .. project_name end

      -- Python projects
      if
        vim.fn.filereadable(cwd .. '/pyproject.toml') == 1
        or vim.fn.filereadable(cwd .. '/setup.py') == 1
        or vim.fn.filereadable(cwd .. '/requirements.txt') == 1
      then
        return ' ' .. project_name
      end

      -- Git repositories
      if vim.fn.isdirectory(cwd .. '/.git') == 1 then return ' ' .. project_name end

      return ' ' .. project_name
    end

    local function get_lsp_status()
      local clients = vim.lsp.get_clients({
        bufnr = 0,
      })
      if #clients == 0 then return '' end

      local client_names = {}
      for _, client in pairs(clients) do
        table.insert(client_names, client.name)
      end

      return ' ' .. table.concat(client_names, ', ')
    end

    local function get_tag_status()
      local tag_file = vim.fn.expand('%:p:h') .. '/tags'
      if vim.fn.filereadable(tag_file) == 1 then
        local mtime = vim.fn.getftime(tag_file)
        local current_time = os.time()
        local age = current_time - mtime

        -- If tags are older than 1 hour, show updating status
        if age > 3600 then
          return ' Updating...'
        else
          return ' Tags Ready'
        end
      end
      return ''
    end

    local function java_version()
      if vim.bo.filetype == 'java' then return ' Java' end
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
            get_project_name,
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
            get_tag_status,
            color = function()
              local status = get_tag_status()
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
            get_lsp_status,
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
          {
            function()
              local format = vim.bo.fileformat
              if format == 'unix' then
                return ' '
              elseif format == 'dos' then
                return ' '
              elseif format == 'mac' then
                return ' '
              else
                return format
              end
            end,
            color = {
              fg = '#89b4fa',
              gui = 'bold',
            },
          },
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
