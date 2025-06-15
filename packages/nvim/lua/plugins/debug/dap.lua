-- DAP (Debug Adapter Protocol) configuration
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go', -- Go debugging support
  },
  config = function()
    local dap = require('dap')

    -- Define sign icons for breakpoints and stopped position
    vim.fn.sign_define('DapBreakpoint', {
      text = '●',
      texthl = 'DapBreakpoint',
      linehl = '',
      numhl = '',
    })
    vim.fn.sign_define('DapBreakpointCondition', {
      text = '◆',
      texthl = 'DapBreakpointCondition',
      linehl = '',
      numhl = '',
    })
    vim.fn.sign_define('DapLogPoint', {
      text = '◆',
      texthl = 'DapLogPoint',
      linehl = '',
      numhl = '',
    })
    vim.fn.sign_define('DapStopped', {
      text = '▶',
      texthl = 'DapStopped',
      linehl = 'DapStopped',
      numhl = 'DapStopped',
    })
    vim.fn.sign_define('DapBreakpointRejected', {
      text = '●',
      texthl = 'DapBreakpointRejected',
      linehl = '',
      numhl = '',
    })

    -- Configure Mason-nvim-dap to ensure adapters are installed
    require('mason-nvim-dap').setup({
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        'codelldb', -- C/C++/Rust
        'delve', -- Go
        'java-debug-adapter',
        'java-test',
      },
    })

    -- Add language-specific configurations
    -- C/C++/Rust configuration with codelldb
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = vim.fn.exepath('codelldb'),
        args = { '--port', '${port}' },
      },
    }

    -- Java configuration with enhanced support for Gradle projects
    dap.configurations.java = {
      {
        type = 'java',
        request = 'launch',
        name = 'Debug (Launch) - Current Class',
        mainClass = function() return vim.fn.input('Main class: ', '', 'file') end,
        projectName = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':t') end,
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        stopOnEntry = false,
        args = '',
        vmArgs = '-ea', -- Enable assertions
      },
      {
        type = 'java',
        request = 'launch',
        name = 'Debug (Launch) - Gradle Application',
        mainClass = '',
        projectName = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':t') end,
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        stopOnEntry = false,
        args = '',
        vmArgs = '-ea',
        preLaunchTask = 'gradle:build',
      },
      {
        type = 'java',
        request = 'launch',
        name = 'Debug (Launch) - Spring Boot Application',
        mainClass = '',
        projectName = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':t') end,
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        stopOnEntry = false,
        args = '',
        vmArgs = '-ea -Dspring.profiles.active=dev',
        env = {
          SPRING_PROFILES_ACTIVE = 'dev',
        },
      },
      {
        type = 'java',
        request = 'attach',
        name = 'Debug (Attach) - Remote JVM',
        hostName = 'localhost',
        port = function() return tonumber(vim.fn.input('Debug port: ', '5005')) end,
        timeout = 20000,
      },
    }

    -- Install Go-specific config from nvim-dap-go
    require('dap-go').setup({
      delve = {
        -- On Windows delve must be run attached or it crashes.
        detached = vim.fn.has('win32') == 0,
      },
    })
  end,
}
