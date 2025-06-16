-- Overseer: Task runner for build tools and commands
return {
  'stevearc/overseer.nvim',
  dependencies = {
    'rcarriga/nvim-notify', -- For better task notifications
  },
  cmd = {
    'OverseerRun',
    'OverseerToggle',
    'OverseerOpen',
    'OverseerClose',
    'OverseerLoadBundle',
    'OverseerSaveBundle',
    'OverseerDeleteBundle',
    'OverseerRunCmd',
    'OverseerQuickAction',
    'OverseerTaskAction',
  },
  keys = {
    {
      '<leader>or',
      '<cmd>OverseerRun<cr>',
      desc = 'Run Task',
    },
    {
      '<leader>ot',
      '<cmd>OverseerToggle<cr>',
      desc = 'Toggle Overseer',
    },
    {
      '<leader>oa',
      '<cmd>OverseerQuickAction<cr>',
      desc = 'Quick Action',
    },
    {
      '<leader>ob',
      '<cmd>OverseerLoadBundle<cr>',
      desc = 'Load Bundle',
    },
    {
      '<leader>os',
      '<cmd>OverseerSaveBundle<cr>',
      desc = 'Save Bundle',
    },
  },
  config = function()
    local overseer = require('overseer')

    overseer.setup({
      -- Task list configuration
      task_list = {
        direction = 'bottom',
        min_height = 25,
        max_height = 25,
        default_detail = 1,
        bindings = {
          ['?'] = 'ShowHelp',
          ['g?'] = 'ShowHelp',
          ['<CR>'] = 'RunAction',
          ['<C-e>'] = 'Edit',
          ['o'] = 'Open',
          ['<C-v>'] = 'OpenVsplit',
          ['<C-s>'] = 'OpenSplit',
          ['<C-f>'] = 'OpenFloat',
          ['<C-q>'] = 'OpenQuickFix',
          ['p'] = 'TogglePreview',
          ['<C-l>'] = 'IncreaseDetail',
          ['<C-h>'] = 'DecreaseDetail',
          ['L'] = 'IncreaseAllDetail',
          ['H'] = 'DecreaseAllDetail',
          ['['] = 'DecreaseWidth',
          [']'] = 'IncreaseWidth',
          ['{'] = 'PrevTask',
          ['}'] = 'NextTask',
          ['<C-k>'] = 'ScrollOutputUp',
          ['<C-j>'] = 'ScrollOutputDown',
          ['q'] = 'Close',
          ['<Esc>'] = 'Close',
        },
      },

      -- Form configuration
      form = {
        border = 'rounded',
        zindex = 40,
        -- Dimensions can be integers or a float between 0 and 1 (percentage of screen)
        min_width = 80,
        max_width = 0.9,
        width = nil,
        min_height = 10,
        max_height = 0.9,
        height = nil,
        -- Set any window options here (e.g. winhighlight)
        win_opts = {
          winblend = 10,
        },
      },

      -- Task launcher configuration
      task_launcher = {
        -- Set keymap to false to remove default behavior
        -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
        bindings = {
          i = {
            ['<C-s>'] = 'Submit',
            ['<C-c>'] = 'Cancel',
          },
          n = {
            ['<CR>'] = 'Submit',
            ['<C-s>'] = 'Submit',
            ['q'] = 'Cancel',
            ['?'] = 'ShowHelp',
          },
        },
      },

      -- Configure the floating window used for confirmation prompts
      confirm = {
        border = 'rounded',
        zindex = 40,
        -- Dimensions can be integers or a float between 0 and 1 (percentage of screen)
        min_width = 20,
        max_width = 0.5,
        width = nil,
        min_height = 6,
        max_height = 0.9,
        height = nil,
        -- Set any window options here (e.g. winhighlight)
        win_opts = {
          winblend = 10,
        },
      },

      -- Options for the floating window used for task templates that don't have a form
      task_win = {
        border = 'rounded',
        win_opts = {
          winblend = 10,
        },
      },

      -- How to handle task output
      strategy = {
        'toggleterm',
        -- Load your default shell before starting the task
        use_shell = false,
        -- Overwrite the default toggleterm "direction" parameter
        direction = 'horizontal',
        -- Have the toggleterm window close and delete the terminal buffer
        -- when the task is complete
        close_on_exit = false,
        -- Open the toggleterm window when a task starts
        open_on_start = true,
        -- Mirrors the toggleterm "hidden" parameter, and keeps the task from
        -- being rendered in the toggleterm sidebar
        hidden = false,
        -- Reuse the same terminal for multiple tasks
        auto_scroll = true,
        quit_on_exit = 'never',
        -- Use a specific terminal ID to reuse the same terminal
        count = 99, -- Use terminal 99 for overseer tasks
        -- Command to run when the terminal opens
        on_create = function()
          vim.opt_local.foldcolumn = '0'
          vim.opt_local.signcolumn = 'no'
          -- Set up keymaps for the terminal
          vim.keymap.set('n', 'q', '<cmd>close<cr>', {
            buffer = true,
            desc = 'Close terminal',
          })
          vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', {
            buffer = true,
            desc = 'Exit terminal mode',
          })
        end,
      },

      -- Component aliases
      component_aliases = {
        -- Most tasks are initialized with the default components
        default = {
          {
            'display_duration',
            detail_level = 2,
          },
          'on_output_summarize',
          'on_exit_set_status',
          'on_complete_notify',
          'on_complete_dispose',
        },
        -- Tasks from tasks.json use these components
        default_vscode = { 'default', 'on_result_diagnostics' },
      },

      -- A list of task definitions to load
      templates = { 'builtin' },

      -- Configure the default task bundles
      bundles = {
        -- When saving a bundle with OverseerSaveBundle or save_task_bundle(), filter the tasks
        save_task_opts = {
          bundleable = true,
        },
        -- Autostart tasks when they are loaded from a bundle
        autostart_on_load = true,
      },

      -- Configure the action when double-clicking on a task
      actions = {},

      -- Configure the task list
      dap = true,

      -- Log level
      log = {
        {
          type = 'echo',
          level = vim.log.levels.WARN,
        },
        {
          type = 'file',
          filename = 'overseer.log',
          level = vim.log.levels.INFO,
        },
      },
    })

    -- Register custom Java/Gradle task templates
    overseer.register_template({
      name = 'gradle run',
      builder = function()
        local gradle_cmd = vim.fn.filereadable('gradlew') == 1 and './gradlew' or 'gradle'
        return {
          cmd = { gradle_cmd },
          args = { 'run' },
          components = { 'default' },
          cwd = vim.fn.getcwd(),
        }
      end,
      condition = {
        filetype = { 'java' },
        callback = function()
          return vim.fn.filereadable('build.gradle') == 1
            or vim.fn.filereadable('build.gradle.kts') == 1
            or vim.fn.filereadable('settings.gradle') == 1
            or vim.fn.filereadable('settings.gradle.kts') == 1
        end,
      },
    })

    overseer.register_template({
      name = 'gradle build',
      builder = function()
        local gradle_cmd = vim.fn.filereadable('gradlew') == 1 and './gradlew' or 'gradle'
        return {
          cmd = { gradle_cmd },
          args = { 'build' },
          components = { 'default' },
          cwd = vim.fn.getcwd(),
        }
      end,
      condition = {
        filetype = { 'java' },
        callback = function()
          return vim.fn.filereadable('build.gradle') == 1
            or vim.fn.filereadable('build.gradle.kts') == 1
            or vim.fn.filereadable('settings.gradle') == 1
            or vim.fn.filereadable('settings.gradle.kts') == 1
        end,
      },
    })

    overseer.register_template({
      name = 'gradle test',
      builder = function()
        local gradle_cmd = vim.fn.filereadable('gradlew') == 1 and './gradlew' or 'gradle'
        return {
          cmd = { gradle_cmd },
          args = { 'test' },
          components = { 'default' },
          cwd = vim.fn.getcwd(),
        }
      end,
      condition = {
        filetype = { 'java' },
        callback = function()
          return vim.fn.filereadable('build.gradle') == 1
            or vim.fn.filereadable('build.gradle.kts') == 1
            or vim.fn.filereadable('settings.gradle') == 1
            or vim.fn.filereadable('settings.gradle.kts') == 1
        end,
      },
    })

    overseer.register_template({
      name = 'gradle clean',
      builder = function()
        local gradle_cmd = vim.fn.filereadable('gradlew') == 1 and './gradlew' or 'gradle'
        return {
          cmd = { gradle_cmd },
          args = { 'clean' },
          components = { 'default' },
          cwd = vim.fn.getcwd(),
        }
      end,
      condition = {
        filetype = { 'java' },
        callback = function()
          return vim.fn.filereadable('build.gradle') == 1
            or vim.fn.filereadable('build.gradle.kts') == 1
            or vim.fn.filereadable('settings.gradle') == 1
            or vim.fn.filereadable('settings.gradle.kts') == 1
        end,
      },
    })

    overseer.register_template({
      name = 'gradle bootRun',
      builder = function()
        local gradle_cmd = vim.fn.filereadable('gradlew') == 1 and './gradlew' or 'gradle'
        return {
          cmd = { gradle_cmd },
          args = { 'bootRun' },
          components = { 'default' },
          cwd = vim.fn.getcwd(),
        }
      end,
      condition = {
        filetype = { 'java' },
        callback = function()
          -- Check if it's a Spring Boot project
          local build_file = vim.fn.filereadable('build.gradle') == 1 and 'build.gradle' or 'build.gradle.kts'
          if vim.fn.filereadable(build_file) == 1 then
            local content = vim.fn.readfile(build_file)
            for _, line in ipairs(content) do
              if line:match('org%.springframework%.boot') then return true end
            end
          end
          return false
        end,
      },
    })

    -- Create Java-specific keymaps
    local function setup_java_keymaps()
      local java_group = vim.api.nvim_create_augroup('OverseerJavaKeymaps', {
        clear = true,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        group = java_group,
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()

          -- Gradle task shortcuts
          vim.keymap.set(
            'n',
            '<leader>oor',
            function()
              overseer.run_template({
                name = 'gradle run',
              })
            end,
            {
              buffer = bufnr,
              desc = 'Gradle Run',
            }
          )

          vim.keymap.set(
            'n',
            '<leader>oob',
            function()
              overseer.run_template({
                name = 'gradle build',
              })
            end,
            {
              buffer = bufnr,
              desc = 'Gradle Build',
            }
          )

          vim.keymap.set(
            'n',
            '<leader>oot',
            function()
              overseer.run_template({
                name = 'gradle test',
              })
            end,
            {
              buffer = bufnr,
              desc = 'Gradle Test',
            }
          )

          vim.keymap.set(
            'n',
            '<leader>ooc',
            function()
              overseer.run_template({
                name = 'gradle clean',
              })
            end,
            {
              buffer = bufnr,
              desc = 'Gradle Clean',
            }
          )

          vim.keymap.set(
            'n',
            '<leader>ooR',
            function()
              overseer.run_template({
                name = 'gradle bootRun',
              })
            end,
            {
              buffer = bufnr,
              desc = 'Gradle Boot Run (Spring Boot)',
            }
          )

          -- Custom Gradle task
          vim.keymap.set('n', '<leader>oox', function()
            local task = vim.fn.input('Gradle task: ')
            if task ~= '' then
              local gradle_cmd = vim.fn.filereadable('gradlew') == 1 and './gradlew' or 'gradle'
              overseer.run_template({
                name = 'shell',
                params = {
                  cmd = gradle_cmd .. ' ' .. task,
                },
              })
            end
          end, {
            buffer = bufnr,
            desc = 'Custom Gradle Task',
          })
        end,
      })
    end

    -- Set up Java keymaps
    setup_java_keymaps()

    -- Global keymaps for Overseer
    vim.keymap.set('n', '<leader>ol', '<cmd>OverseerToggle<cr>', {
      desc = 'Toggle Overseer',
    })
    vim.keymap.set('n', '<leader>oq', '<cmd>OverseerQuickAction<cr>', {
      desc = 'Overseer Quick Action',
    })
    vim.keymap.set('n', '<leader>on', function()
      vim.cmd('OverseerOpen')
      vim.cmd('OverseerRun')
    end, {
      desc = 'New Overseer Task',
    })
  end,
}
