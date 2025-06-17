-- Project Switcher - Modern project management with fzf-lua
-- Fast project switching with automatic detection and beautiful UI
return {
  'ahmedkhalf/project.nvim',
  dependencies = { 'ibhagwan/fzf-lua', 'rcarriga/nvim-notify' },
  event = 'VeryLazy',
  config = function()
    local project = require('project_nvim')

    -- Configure project detection
    project.setup({
      -- Manual mode doesn't automatically change your root directory, so you have
      -- the option to manually do so using `:ProjectRoot` command.
      manual_mode = false,

      -- Methods of detecting the root directory. The order matters: if one is not
      -- detected, the other is used as fallback. You can also delete or rearangne the
      -- detection methods.
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
      ignore_lsp = {},

      -- Don't calculate root dir on specific directories
      -- Ex: { "~/.cargo/*", ... }
      exclude_dirs = { '~/.cargo/*', '~/.local/*', '~/.cache/*', '/tmp/*', '/var/*', '/usr/*', '/opt/*' },

      -- Show hidden files in fzf-lua file pickers
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
      -- fzf-lua
      datapath = vim.fn.stdpath('data'),
    })

    -- Enhanced project switcher module
    local M = {}

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
      if file then
        file:write(vim.json.encode(projects))
        file:close()
      end
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

      -- Add to front of list
      table.insert(projects, 1, {
        path = path,
        name = name or vim.fn.fnamemodify(path, ':t'),
        last_accessed = os.time(),
        type = M.detect_project_type(path),
      })

      -- Limit to 20 recent projects
      if #projects > 20 then table.remove(projects) end

      save_recent_projects(projects)
    end

    -- Detect project type based on files
    function M.detect_project_type(path)
      local checks = {
        {
          pattern = 'build.gradle',
          type = 'gradle',
          icon = '󱁩',
        },
        {
          pattern = 'build.gradle.kts',
          type = 'gradle',
          icon = '󱁩',
        },
        {
          pattern = 'settings.gradle',
          type = 'gradle',
          icon = '󱁩',
        },
        {
          pattern = 'settings.gradle.kts',
          type = 'gradle',
          icon = '󱁩',
        },
        {
          pattern = 'pom.xml',
          type = 'maven',
          icon = '󰯂',
        },
        {
          pattern = 'package.json',
          type = 'node',
          icon = '󰎙',
        },
        {
          pattern = 'Cargo.toml',
          type = 'rust',
          icon = '󱘗',
        },
        {
          pattern = 'pyproject.toml',
          type = 'python',
          icon = '󰌠',
        },
        {
          pattern = 'setup.py',
          type = 'python',
          icon = '󰌠',
        },
        {
          pattern = 'requirements.txt',
          type = 'python',
          icon = '󰌠',
        },
        {
          pattern = 'go.mod',
          type = 'go',
          icon = '󰟓',
        },
        {
          pattern = 'CMakeLists.txt',
          type = 'cmake',
          icon = '󰙲',
        },
        {
          pattern = 'meson.build',
          type = 'meson',
          icon = '󰙲',
        },
        {
          pattern = '.git',
          type = 'git',
          icon = '󰊢',
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
        icon = '󰝰',
      }
    end

    -- Main project picker using fzf-lua
    function M.project_picker()
      local recent_projects = load_recent_projects()
      if vim.tbl_isempty(recent_projects) then
        vim.notify('No recent projects found', vim.log.levels.INFO)
        return
      end

      -- Sort projects by last accessed time (most recent first)
      table.sort(recent_projects, function(a, b) return a.last_accessed > b.last_accessed end)

      local entries = {}
      for _, proj in ipairs(recent_projects) do
        local relative_path = vim.fn.fnamemodify(proj.path, ':~')
        local entry = string.format('%s %s (%s)', proj.type.icon, proj.name, relative_path)
        table.insert(entries, entry)
      end

      require('fzf-lua').fzf_exec(entries, {
        prompt = '󰘬 Recent Projects❯ ',
        winopts = {
          title = ' 󰘬 Project Switcher ',
          title_pos = 'center',
        },
        actions = {
          ['default'] = function(selected)
            if selected and #selected > 0 then
              local entry = selected[1]
              -- Find the matching project
              for _, proj in ipairs(recent_projects) do
                local relative_path = vim.fn.fnamemodify(proj.path, ':~')
                local display = string.format('%s %s (%s)', proj.type.icon, proj.name, relative_path)
                if display == entry then
                  M.switch_to_project(proj.path, proj.name)
                  break
                end
              end
            end
          end,
          ['ctrl-d'] = function(selected)
            if selected and #selected > 0 then
              local entry = selected[1]
              -- Find the matching project and remove it
              for _, proj in ipairs(recent_projects) do
                local relative_path = vim.fn.fnamemodify(proj.path, ':~')
                local display = string.format('%s %s (%s)', proj.type.icon, proj.name, relative_path)
                if display == entry then
                  M.remove_recent_project(proj.path)
                  -- Reopen the picker
                  vim.schedule(M.project_picker)
                  break
                end
              end
            end
          end,
          ['ctrl-e'] = function(selected)
            if selected and #selected > 0 then
              local entry = selected[1]
              -- Find the matching project and open in file manager
              for _, proj in ipairs(recent_projects) do
                local relative_path = vim.fn.fnamemodify(proj.path, ':~')
                local display = string.format('%s %s (%s)', proj.type.icon, proj.name, relative_path)
                if display == entry then
                  if vim.fn.has('mac') == 1 then
                    vim.fn.jobstart({ 'open', proj.path }, {
                      detach = true,
                    })
                  elseif vim.fn.has('unix') == 1 then
                    vim.fn.jobstart({ 'xdg-open', proj.path }, {
                      detach = true,
                    })
                  end
                  break
                end
              end
            end
          end,
        },
        fzf_opts = {
          ['--header'] = 'Enter=switch, Ctrl-d=remove, Ctrl-e=open in file manager',
        },
      })
    end

    -- Switch to project
    function M.switch_to_project(path, name)
      if vim.fn.isdirectory(path) == 0 then
        vim.notify('Project directory does not exist: ' .. path, vim.log.levels.ERROR)
        return
      end

      -- Change directory
      vim.cmd('cd ' .. vim.fn.fnameescape(path))

      -- Add to recent projects
      add_recent_project(path, name)

      -- Notify user
      local project_type = M.detect_project_type(path)
      vim.notify(
        string.format(
          'Switched to %s %s project: %s',
          project_type.icon,
          project_type.type,
          name or vim.fn.fnamemodify(path, ':t')
        ),
        vim.log.levels.INFO
      )

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
      vim.notify('Removed project from recent list', vim.log.levels.INFO)
    end

    -- Interactive project removal using fzf-lua
    function M.remove_project_interactive()
      local recent_projects = load_recent_projects()
      if #recent_projects == 0 then
        vim.notify('No recent projects to remove', vim.log.levels.WARN)
        return
      end

      local entries = {}
      for _, proj in ipairs(recent_projects) do
        local relative_path = vim.fn.fnamemodify(proj.path, ':~')
        local entry = string.format('%s %s (%s)', proj.type.icon, proj.name, relative_path)
        table.insert(entries, entry)
      end

      require('fzf-lua').fzf_exec(entries, {
        prompt = '󰆴 Remove Project❯ ',
        winopts = {
          title = ' 󰆴 Remove Project from Recent List ',
          title_pos = 'center',
        },
        actions = {
          ['default'] = function(selected)
            if selected and #selected > 0 then
              local entry = selected[1]
              -- Find the matching project
              for _, proj in ipairs(recent_projects) do
                local relative_path = vim.fn.fnamemodify(proj.path, ':~')
                local display = string.format('%s %s (%s)', proj.type.icon, proj.name, relative_path)
                if display == entry then
                  local confirm =
                    vim.fn.confirm('Remove project "' .. proj.name .. '" from recent list?', '&Yes\n&No', 2)
                  if confirm == 1 then M.remove_recent_project(proj.path) end
                  break
                end
              end
            end
          end,
        },
      })
    end

    -- Add current directory as project
    function M.add_current_project()
      local cwd = vim.fn.getcwd()
      local name = vim.fn.input('Project name: ', vim.fn.fnamemodify(cwd, ':t'))

      if name and name ~= '' then
        add_recent_project(cwd, name)
        vim.notify('Added current directory as project: ' .. name, vim.log.levels.INFO)
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
    vim.api.nvim_create_user_command('ProjectSwitch', M.project_picker, {
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
    vim.keymap.set('n', '<leader>pp', M.project_picker, {
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

    -- Export module for other plugins to use
    _G.ProjectSwitcher = M
  end,
}
