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

    -- Define sign icons for breakpoints and stopped position with nerd font icons
    vim.fn.sign_define('DapBreakpoint', {
      text = '',
      texthl = 'DapBreakpoint',
      linehl = '',
      numhl = '',
    })
    vim.fn.sign_define('DapBreakpointCondition', {
      text = '',
      texthl = 'DapBreakpointCondition',
      linehl = '',
      numhl = '',
    })
    vim.fn.sign_define('DapLogPoint', {
      text = '',
      texthl = 'DapLogPoint',
      linehl = '',
      numhl = '',
    })
    vim.fn.sign_define('DapStopped', {
      text = '',
      texthl = 'DapStopped',
      linehl = 'DapStopped',
      numhl = 'DapStopped',
    })
    vim.fn.sign_define('DapBreakpointRejected', {
      text = '',
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

    -- Java adapter configuration with improved error handling
    dap.adapters.java = function(callback, config)
      -- First check if Mason registry is available
      local mason_registry_ok, mason_registry = pcall(require, 'mason-registry')
      if not mason_registry_ok then
        vim.notify('Mason registry not available for Java debugger', vim.log.levels.ERROR)
        return
      end

      -- Check if java-debug-adapter package exists in registry
      local package_exists = mason_registry.has_package('java-debug-adapter')
      if not package_exists then
        vim.notify(
          'Java debug adapter package not found in Mason registry. Install with :MasonInstall java-debug-adapter',
          vim.log.levels.ERROR
        )
        return
      end

      -- Get the package and check if it's installed
      local java_debug_adapter_ok, java_debug_adapter = pcall(mason_registry.get_package, 'java-debug-adapter')
      if not java_debug_adapter_ok or not java_debug_adapter then
        vim.notify(
          'Failed to get Java debug adapter package. Install with :MasonInstall java-debug-adapter',
          vim.log.levels.ERROR
        )
        return
      end

      -- Check if the package is actually installed
      local is_installed_ok, is_installed = pcall(function() return java_debug_adapter:is_installed() end)
      if not is_installed_ok or not is_installed then
        vim.notify(
          'Java debug adapter not installed. Install with :MasonInstall java-debug-adapter',
          vim.log.levels.ERROR
        )
        return
      end

      -- Get the installation path
      local install_path_ok, java_debug_path = pcall(function() return java_debug_adapter:get_install_path() end)
      if not install_path_ok or not java_debug_path then
        vim.notify('Could not get Java debug adapter install path', vim.log.levels.ERROR)
        return
      end

      -- Look for the JAR file with more robust path checking
      local jar_pattern = java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'
      local jar_path = vim.fn.glob(jar_pattern)

      if jar_path == '' or jar_path == nil then
        -- Try alternative path structure
        local alt_jar_pattern = java_debug_path .. '/server/com.microsoft.java.debug.plugin-*.jar'
        jar_path = vim.fn.glob(alt_jar_pattern)

        if jar_path == '' or jar_path == nil then
          vim.notify(
            'Java debug adapter JAR not found. Tried:\n'
              .. jar_pattern
              .. '\n'
              .. alt_jar_pattern
              .. '\n'
              .. 'Reinstall with :MasonUninstall java-debug-adapter then :MasonInstall java-debug-adapter',
            vim.log.levels.ERROR
          )
          return
        end
      end

      -- Verify the JAR file actually exists
      if vim.fn.filereadable(jar_path) ~= 1 then
        vim.notify(
          'Java debug adapter JAR file is not readable: '
            .. jar_path
            .. '\n'
            .. 'Reinstall with :MasonUninstall java-debug-adapter then :MasonInstall java-debug-adapter',
          vim.log.levels.ERROR
        )
        return
      end

      -- Successfully configured - call the callback
      callback({
        type = 'executable',
        command = 'java',
        args = { '-jar', jar_path },
      })
    end

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
