-- Project switcher with recent projects tracking
return {
  'ahmedkhalf/project.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim', 'rcarriga/nvim-notify' },
  event = 'VeryLazy',
  config = function()
    local project = require('project_nvim')

    project.setup({
      -- Manual mode doesn't automatically change your root directory, so you have
      -- the option to manually do so using `:ProjectRoot` command.
      manual_mode = false,

      -- Methods of detecting the root directory. **"lsp"** uses the native neovim
      -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
      -- order matters: if one is not detected, the other is used as fallback. You
      -- can also delete or rearangne the detection methods.
      detection_methods = { 'lsp', 'pattern' },

      -- All the patterns used to detect root dir, when **"pattern"** is in
      -- detection_methods
      patterns = {
        '.git',
        '_darcs',
        '.hg',
        '.bzr',
        '.svn',
        'Makefile',
        'package.json',
        'pom.xml',
        'build.gradle',
        'build.gradle.kts',
        'settings.gradle',
        'settings.gradle.kts',
        'gradlew',
        'Cargo.toml',
        'pyproject.toml',
        'setup.py',
        'requirements.txt',
        'CMakeLists.txt',
        'meson.build',
        '.project',
        '.classpath',
        'go.mod',
        'composer.json',
        'mix.exs',
        'rebar.config',
        'erlang.mk',
      },

      -- Table of lsp clients to ignore by name
      -- eg: { "efm", ... }
      ignore_lsp = {},

      -- Don't calculate root dir on specific directories
      -- Ex: { "~/.cargo/*", ... }
      exclude_dirs = { '~/.cargo/*', '~/.local/*', '~/.cache/*', '/tmp/*', '/var/*', '/usr/*', '/opt/*' },

      -- Show hidden files in telescope
      show_hidden = false,

      -- When set to false, you will get a message when project.nvim changes your
      -- directory.
      silent_chdir = true,

      -- What scope to change the directory, valid options are
      -- * global (default)
      -- * tab
      -- * win
      scope_chdir = 'global',

      -- Path where project.nvim will store the project history for use in
      -- telescope
      datapath = vim.fn.stdpath('data'),
    })

    -- Enhanced project switcher functionality
    local M = {}

    -- Custom project data storage
    local projects_file = vim.fn.stdpath('data') .. '/recent_projects.json'

    -- Load recent projects from file
    local function load_recent_projects()
      local file = io.open(projects_file, 'r')
      if not file then return {} end

      local content = file:read('*all')
      file:close()

      local ok, projects = pcall(vim.json.decode, content)
      if ok and type(projects) == 'table' then return projects end

      return {}
    end

    -- Save recent projects to file
    local function save_recent_projects(projects)
      local file = io.open(projects_file, 'w')
      if not file then
        require('utils.notify').error('Failed to save recent projects')
        return
      end

      file:write(vim.json.encode(projects))
      file:close()
    end

    -- Add project to recent list
    local function add_recent_project(path, name)
      local projects = load_recent_projects()

      -- Remove if already exists
      for i, project in ipairs(projects) do
        if project.path == path then
          table.remove(projects, i)
          break
        end
      end

      -- Add to beginning
      table.insert(projects, 1, {
        path = path,
        name = name or vim.fn.fnamemodify(path, ':t'),
        last_accessed = os.time(),
        type = M.detect_project_type(path),
      })

      -- Keep only last 20 projects
      if #projects > 20 then
        for i = 21, #projects do
          projects[i] = nil
        end
      end

      save_recent_projects(projects)
    end

    -- Detect project type based on files
    function M.detect_project_type(path)
      local checks = {
        {
          pattern = 'build.gradle',
          type = 'gradle',
          icon = '📦',
        },
        {
          pattern = 'build.gradle.kts',
          type = 'gradle',
          icon = '📦',
        },
        {
          pattern = 'settings.gradle',
          type = 'gradle',
          icon = '📦',
        },
        {
          pattern = 'settings.gradle.kts',
          type = 'gradle',
          icon = '📦',
        },
        {
          pattern = 'pom.xml',
          type = 'maven',
          icon = '📦',
        },
        {
          pattern = 'package.json',
          type = 'node',
          icon = '📦',
        },
        {
          pattern = 'Cargo.toml',
          type = 'rust',
          icon = '🦀',
        },
        {
          pattern = 'pyproject.toml',
          type = 'python',
          icon = '🐍',
        },
        {
          pattern = 'setup.py',
          type = 'python',
          icon = '🐍',
        },
        {
          pattern = 'requirements.txt',
          type = 'python',
          icon = '🐍',
        },
        {
          pattern = 'go.mod',
          type = 'go',
          icon = '🐹',
        },
        {
          pattern = 'CMakeLists.txt',
          type = 'cmake',
          icon = '🔧',
        },
        {
          pattern = 'meson.build',
          type = 'meson',
          icon = '🔧',
        },
        {
          pattern = '.git',
          type = 'git',
          icon = '📁',
        },
      }

      for _, check in ipairs(checks) do
        if
          vim.fn.filereadable(path .. '/' .. check.pattern) == 1
          or vim.fn.isdirectory(path .. '/' .. check.pattern) == 1
        then
          return {
            type = check.type,
            icon = check.icon,
          }
        end
      end

      return {
        type = 'unknown',
        icon = '📁',
      }
    end

    -- Enhanced telescope project picker
    function M.telescope_projects()
      local telescope = require('telescope')
      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf = require('telescope.config').values
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      local themes = require('telescope.themes')

      local recent_projects = load_recent_projects()

      -- Format projects for display
      local formatted_projects = {}
      for _, proj in ipairs(recent_projects) do
        local display = string.format('%s %s (%s)', proj.type.icon, proj.name, vim.fn.fnamemodify(proj.path, ':~'))
        table.insert(formatted_projects, {
          display = display,
          path = proj.path,
          name = proj.name,
          type = proj.type,
          last_accessed = proj.last_accessed,
        })
      end

      pickers
        .new(themes.get_ivy({
          prompt_title = '🚀 Recent Projects',
          finder = finders.new_table({
            results = formatted_projects,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.display,
                ordinal = entry.name .. ' ' .. entry.path,
              }
            end,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)

              if selection then M.switch_to_project(selection.value.path, selection.value.name) end
            end)

            -- Add mapping to remove project from recent list
            map('n', '<C-d>', function()
              local selection = action_state.get_selected_entry()
              if selection then
                M.remove_recent_project(selection.value.path)
                -- Refresh the picker
                M.telescope_projects()
              end
            end)

            return true
          end,
        }))
        :find()
    end

    -- Switch to project
    function M.switch_to_project(path, name)
      if vim.fn.isdirectory(path) == 0 then
        require('utils.notify').error('Project directory does not exist: ' .. path)
        return
      end

      -- Change directory
      vim.cmd('cd ' .. vim.fn.fnameescape(path))

      -- Add to recent projects
      add_recent_project(path, name)

      -- Notify user
      local project_type = M.detect_project_type(path)
      require('utils.notify').project_switched(name or vim.fn.fnamemodify(path, ':t'), project_type.type)

      -- Trigger project change events
      vim.api.nvim_exec_autocmds('User', {
        pattern = 'ProjectChanged',
      })
    end

    -- Remove project from recent list
    function M.remove_recent_project(path)
      local projects = load_recent_projects()

      for i, project in ipairs(projects) do
        if project.path == path then
          table.remove(projects, i)
          break
        end
      end

      save_recent_projects(projects)
      require('utils.notify').success('Removed project from recent list')
    end

    -- Interactive project removal
    function M.remove_project_interactive()
      local recent_projects = load_recent_projects()
      if #recent_projects == 0 then
        require('utils.notify').warn('No recent projects to remove')
        return
      end

      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf = require('telescope.config').values
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      local themes = require('telescope.themes')

      local formatted_projects = {}
      for _, proj in ipairs(recent_projects) do
        local display = string.format('%s %s (%s)', proj.type.icon, proj.name, vim.fn.fnamemodify(proj.path, ':~'))
        table.insert(formatted_projects, {
          display = display,
          path = proj.path,
          name = proj.name,
          type = proj.type,
          last_accessed = proj.last_accessed,
        })
      end

      pickers
        .new(
          themes.get_ivy({
            prompt_title = '🗑️  Remove Project',
            layout_config = {
              height = 0.4,
            },
          }),
          {
            finder = finders.new_table({
              results = formatted_projects,
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = entry.display,
                  ordinal = entry.name .. ' ' .. entry.path,
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                if selection then
                  -- Confirm removal
                  local confirm =
                    vim.fn.confirm('Remove project "' .. selection.value.name .. '" from recent list?', '&Yes\n&No', 2)
                  if confirm == 1 then M.remove_recent_project(selection.value.path) end
                end
              end)

              return true
            end,
          }
        )
        :find()
    end

    -- Add current directory as project
    function M.add_current_project()
      local cwd = vim.fn.getcwd()
      local name = vim.fn.input('Project name: ', vim.fn.fnamemodify(cwd, ':t'))

      if name and name ~= '' then
        add_recent_project(cwd, name)
        require('utils.notify').success('Added current directory as project: ' .. name)
      end
    end

    -- Auto-add projects when changing directories
    local function auto_add_project()
      local cwd = vim.fn.getcwd()
      local project_type = M.detect_project_type(cwd)

      -- Only auto-add if it's a recognized project type
      if project_type.type ~= 'unknown' then add_recent_project(cwd, vim.fn.fnamemodify(cwd, ':t')) end
    end

    -- Setup auto-commands
    local project_group = vim.api.nvim_create_augroup('ProjectSwitcher', {
      clear = true,
    })

    vim.api.nvim_create_autocmd('DirChanged', {
      group = project_group,
      callback = auto_add_project,
    })

    -- Commands
    vim.api.nvim_create_user_command('ProjectSwitch', M.telescope_projects, {
      desc = 'Switch to a recent project',
    })

    vim.api.nvim_create_user_command('ProjectAdd', M.add_current_project, {
      desc = 'Add current directory as a project',
    })

    vim.api.nvim_create_user_command('ProjectRemove', function()
      local cwd = vim.fn.getcwd()
      M.remove_recent_project(cwd)
    end, {
      desc = 'Remove current project from recent list',
    })

    vim.api.nvim_create_user_command('ProjectRemoveInteractive', M.remove_project_interactive, {
      desc = 'Remove project from recent list (interactive)',
    })

    -- Keymaps
    vim.keymap.set('n', '<leader>pp', M.telescope_projects, {
      desc = 'Switch Project',
    })

    vim.keymap.set('n', '<leader>pa', M.add_current_project, {
      desc = 'Add Current Project',
    })

    vim.keymap.set('n', '<leader>pr', function() M.remove_recent_project(vim.fn.getcwd()) end, {
      desc = 'Remove Current Project',
    })

    vim.keymap.set('n', '<leader>pR', M.remove_project_interactive, {
      desc = 'Remove Project (Interactive)',
    })

    -- Integration with telescope
    pcall(require('telescope').load_extension, 'projects')

    -- Export module for other plugins to use
    _G.ProjectSwitcher = M
  end,
}
