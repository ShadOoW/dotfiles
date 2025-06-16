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

    -- Java adapter - use the actual debug adapter JAR
    dap.adapters.java = function(callback, config)
      -- Find the debug adapter JAR
      local mason_path = vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter'
      local jar_path = vim.fn.glob(mason_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar')

      if jar_path == '' then
        vim.notify(
          'Java debug adapter JAR not found. Please install via Mason: :MasonInstall java-debug-adapter',
          vim.log.levels.ERROR
        )
        return
      end

      -- Check if JDTLS is running
      local jdtls_clients = vim.lsp.get_clients({
        name = 'jdtls',
      })
      if #jdtls_clients == 0 then
        vim.notify('JDTLS is not running. Please open a Java file first.', vim.log.levels.ERROR)
        return
      end

      -- Use JDTLS to start the debug session
      vim.lsp.buf_request(0, 'workspace/executeCommand', {
        command = 'vscode.java.startDebugSession',
        arguments = {},
      }, function(err, result)
        if err then
          vim.notify('Error starting debug session: ' .. tostring(err), vim.log.levels.ERROR)
          -- Fallback to fixed port
          callback({
            type = 'server',
            host = '127.0.0.1',
            port = 5005,
          })
          return
        end

        local port = result
        if port and type(port) == 'number' then
          callback({
            type = 'server',
            host = '127.0.0.1',
            port = port,
          })
        else
          -- Fallback to fixed port
          callback({
            type = 'server',
            host = '127.0.0.1',
            port = 5005,
          })
        end
      end)
    end

    -- Java configurations - complete setup with required fields
    dap.configurations.java = {
      {
        type = 'java',
        request = 'launch',
        name = 'Debug (Launch) - Current Class',
        mainClass = function()
          -- Get the current class name from the file
          local current_file = vim.fn.expand('%:p')
          if current_file:match('%.java$') then
            -- Extract package and class name from file content
            local lines = vim.fn.readfile(current_file)
            local package_name = ''
            local class_name = current_file:match('([^/\\]+)%.java$')

            -- Look for package declaration
            for _, line in ipairs(lines) do
              local pkg = line:match('^package%s+([%w%.]+);')
              if pkg then
                package_name = pkg .. '.'
                break
              end
            end

            if class_name then return package_name .. class_name end
          end
          return vim.fn.input('Main class (fully qualified): ', '', 'file')
        end,
        projectName = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':t') end,
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        stopOnEntry = false,
        args = function()
          local input = vim.fn.input('Program arguments: ')
          return input ~= '' and vim.split(input, ' ') or {}
        end,
        vmArgs = '-ea',
        modulePaths = {},
        classPaths = { '${workspaceFolder}' },
      },
      {
        type = 'java',
        request = 'launch',
        name = 'Debug (Launch) - Main Method',
        mainClass = function() return vim.fn.input('Main class (fully qualified): ', '', 'file') end,
        projectName = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':t') end,
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        stopOnEntry = false,
        args = function()
          local input = vim.fn.input('Program arguments: ')
          return input ~= '' and vim.split(input, ' ') or {}
        end,
        vmArgs = '-ea',
        modulePaths = {},
        classPaths = { '${workspaceFolder}' },
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
