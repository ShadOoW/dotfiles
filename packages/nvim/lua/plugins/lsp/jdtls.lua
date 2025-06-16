return {
  'mfussenegger/nvim-jdtls',
  dependencies = { 'neovim/nvim-lspconfig', 'mfussenegger/nvim-dap', 'williamboman/mason.nvim' },
  ft = { 'java' },
  config = function()
    local jdtls = require('jdtls')
    local handlers = require('lsp.handlers')

    -- Find root directory based on maven or gradle files or source directories
    local root_markers = { -- Prioritize project-level files (these should be found first)
      'settings.gradle.kts',
      'settings.gradle',
      'gradlew',
      'gradle.properties',
      'pom.xml',
      'mvnw',
      -- Then build files (these might be in submodules)
      'build.gradle.kts',
      'build.gradle', -- Git repository (good fallback)
      '.git', -- Eclipse project files
      '.classpath',
      '.project', -- Source directories (lowest priority - only use if nothing else found)
      'src/main/java',
      'src',
      'java',
    }

    local function find_gradle_project_root(start_path)
      local current_dir = start_path or vim.fn.expand('%:p:h')

      -- Walk up the directory tree
      while current_dir ~= '/' and current_dir ~= '' do
        -- Check for settings.gradle files first (these define the project root)
        if
          vim.fn.filereadable(current_dir .. '/settings.gradle.kts') == 1
          or vim.fn.filereadable(current_dir .. '/settings.gradle') == 1
        then
          return current_dir
        end

        -- Check for gradlew (also indicates project root)
        if vim.fn.filereadable(current_dir .. '/gradlew') == 1 then return current_dir end

        current_dir = vim.fn.fnamemodify(current_dir, ':h')
      end

      return nil
    end

    local function get_jdtls_paths()
      local path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
      local path_to_config = path .. '/config_linux'
      local path_to_plugins = path .. '/plugins'
      local path_to_jar = vim.fn.glob(path_to_plugins .. '/org.eclipse.equinox.launcher_*.jar')
      local lombok_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls/lombok.jar'

      -- Check if JDTLS is properly installed
      if path_to_jar == '' then
        vim.notify('JDTLS launcher not found. Please install via Mason: :MasonInstall jdtls', vim.log.levels.ERROR)
        return nil
      end

      -- Try to find Java installation more robustly
      local java_paths = {
        '/usr/lib/jvm/java-8-openjdk/bin/java', -- Moved Java 8 to first priority
        '/usr/lib/jvm/java-11-openjdk/bin/java',
        '/usr/lib/jvm/java-17-openjdk/bin/java',
        '/usr/lib/jvm/java-21-openjdk/bin/java',
        '/usr/lib/jvm/java-24-openjdk/bin/java',
        '/usr/bin/java',
      }

      local java_path = nil
      for _, path in ipairs(java_paths) do
        if vim.fn.executable(path) == 1 then
          java_path = path
          break
        end
      end

      if not java_path then
        vim.notify('No suitable Java installation found', vim.log.levels.ERROR)
        return nil
      end

      return {
        java_path = java_path,
        launcher = path_to_jar,
        config = path_to_config,
        plugins = path_to_plugins,
        lombok = lombok_path,
      }
    end

    local function jdtls_setup(event)
      -- Check if JDTLS is already running for this buffer
      local existing_clients = vim.lsp.get_clients({
        name = 'jdtls',
      })
      for _, client in ipairs(existing_clients) do
        if vim.lsp.buf_is_attached(0, client.id) then
          print('JDTLS already attached to this buffer')
          return
        end
      end

      local paths = get_jdtls_paths()
      if not paths then return end

      -- First try our custom Gradle root detection
      local root_dir = find_gradle_project_root()

      -- If that fails, fall back to jdtls.setup.find_root with prioritized markers
      if not root_dir then root_dir = require('jdtls.setup').find_root(root_markers) end

      -- If still no root found, use current working directory
      if not root_dir or root_dir == '' then
        root_dir = vim.fn.getcwd()
        print('JDTLS: Using current working directory as fallback: ' .. root_dir)
      end

      -- Validate that this looks like a Gradle project
      local has_gradle_files = vim.fn.filereadable(root_dir .. '/settings.gradle.kts') == 1
        or vim.fn.filereadable(root_dir .. '/settings.gradle') == 1
        or vim.fn.filereadable(root_dir .. '/gradlew') == 1

      if not has_gradle_files then print('JDTLS: Warning - No Gradle files found in root: ' .. root_dir) end

      print('JDTLS: Using project root: ' .. root_dir)

      -- Create data directory for each project (use a hash to avoid long paths)
      local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
      -- Add hash of full path to make workspace unique and avoid conflicts
      local path_hash = vim.fn.sha256(root_dir):sub(1, 8)
      local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name .. '_' .. path_hash

      -- Make sure the directory exists
      vim.fn.mkdir(workspace_dir, 'p')

      -- Get capabilities and optimize for Java completion like IntelliJ IDEA
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Enhanced completion capabilities for Java
      capabilities.textDocument.completion.completionItem.snippetSupport = false
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
          'documentation',
          'detail',
          'additionalTextEdits',
          'sortText',
          'filterText',
          'insertText',
          'textEdit',
          'insertTextFormat',
        },
      }

      -- Enable advanced completion features
      capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
      capabilities.textDocument.completion.completionItem.deprecatedSupport = true
      capabilities.textDocument.completion.completionItem.preselectSupport = true
      capabilities.textDocument.completion.completionItem.tagSupport = {
        valueSet = { 1 }, -- Deprecated
      }
      capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
      capabilities.textDocument.completion.completionItem.labelDetailsSupport = true

      -- Enhanced completion context
      capabilities.textDocument.completion.contextSupport = true

      -- Custom LSP handlers to suppress duplicate notifications
      local custom_handlers = {}

      -- Suppress window/showMessage notifications (but keep them in lualine status)
      custom_handlers['window/showMessage'] = function(err, result, ctx, config)
        -- Don't show notifications for progress messages, just log them
        if result and result.message then
          -- Only log important messages, suppress routine ones
          if result.type == 1 then -- Error
            vim.notify(result.message, vim.log.levels.ERROR)
          elseif result.type == 2 and not result.message:match('Loading') and not result.message:match('Building') then -- Warning
            vim.notify(result.message, vim.log.levels.WARN)
          end
          -- Suppress Info (3) and Log (4) level messages to avoid duplicates
        end
        return result
      end

      -- Suppress window/showMessageRequest (but keep in status)
      custom_handlers['window/showMessageRequest'] = function(err, result, ctx, config)
        -- Let status line show these, don't popup notifications
        return result
      end

      -- Add custom error handler for buffer issues
      custom_handlers['textDocument/definition'] = function(err, result, ctx, config)
        if err then
          vim.notify('LSP Definition Error: ' .. tostring(err), vim.log.levels.WARN)
          return
        end

        -- Use pcall to safely handle buffer operations
        local success, error_msg = pcall(vim.lsp.handlers['textDocument/definition'], err, result, ctx, config)
        if not success then vim.notify('Buffer operation failed: ' .. tostring(error_msg), vim.log.levels.WARN) end
      end

      -- Get bundles for debugging and testing using Mason registry (same as DAP config)
      local bundles = {}

      -- Use Mason registry for consistent detection with API fallback
      local mason_registry_ok, mason_registry = pcall(require, 'mason-registry')
      if mason_registry_ok then
        -- Java Debug Adapter
        local java_debug_ok, java_debug_adapter = pcall(mason_registry.get_package, 'java-debug-adapter')
        if java_debug_ok and java_debug_adapter:is_installed() then
          -- Get install path with fallback for different Mason API versions
          local java_debug_path
          if java_debug_adapter.get_install_path then
            local path_ok, path = pcall(function() return java_debug_adapter:get_install_path() end)
            if path_ok and path then java_debug_path = path end
          end

          -- Fallback to manual path construction
          if not java_debug_path then
            java_debug_path = vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter'
          end

          local jar_pattern = java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'
          local java_debug_bundle = vim.fn.glob(jar_pattern)

          if java_debug_bundle ~= '' then
            vim.list_extend(bundles, { java_debug_bundle })
            print('JDTLS: Found Java debug adapter: ' .. java_debug_bundle)
          else
            print('JDTLS: Java debug adapter JAR not found at: ' .. jar_pattern)
          end
        else
          print('JDTLS: Java debug adapter not installed. Install with: :MasonInstall java-debug-adapter')
        end

        -- Java Test
        local java_test_ok, java_test = pcall(mason_registry.get_package, 'java-test')
        if java_test_ok and java_test:is_installed() then
          -- Get install path with fallback for different Mason API versions
          local java_test_path
          if java_test.get_install_path then
            local path_ok, path = pcall(function() return java_test:get_install_path() end)
            if path_ok and path then java_test_path = path end
          end

          -- Fallback to manual path construction
          if not java_test_path then java_test_path = vim.fn.stdpath('data') .. '/mason/packages/java-test' end

          local test_jar_pattern = java_test_path .. '/extension/server/*.jar'
          local java_test_bundles = vim.fn.glob(test_jar_pattern, true, true)

          if not vim.tbl_isempty(java_test_bundles) then
            vim.list_extend(bundles, java_test_bundles)
            print('JDTLS: Found Java test bundles: ' .. #java_test_bundles .. ' files')
          else
            print('JDTLS: Java test bundles not found at: ' .. test_jar_pattern)
          end
        else
          print('JDTLS: Java test not installed. Install with: :MasonInstall java-test')
        end
      else
        print('JDTLS: Mason registry not available, falling back to manual detection')

        -- Fallback to manual detection
        local mason_path = vim.fn.stdpath('data') .. '/mason/packages/'

        local java_debug_path = mason_path .. 'java-debug-adapter/extension/server/'
        local java_debug_bundle = vim.fn.glob(java_debug_path .. 'com.microsoft.java.debug.plugin-*.jar')
        if java_debug_bundle ~= '' then
          vim.list_extend(bundles, { java_debug_bundle })
          print('JDTLS: Found Java debug adapter (fallback): ' .. java_debug_bundle)
        end

        local java_test_path = mason_path .. 'java-test/extension/server/*.jar'
        local java_test_bundles = vim.fn.glob(java_test_path, true, true)
        if not vim.tbl_isempty(java_test_bundles) then
          vim.list_extend(bundles, java_test_bundles)
          print('JDTLS: Found Java test bundles (fallback): ' .. #java_test_bundles .. ' files')
        end
      end

      -- Main config
      local cmd = {
        paths.java_path, -- Path to Java executable
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ERROR', -- Reduce log level from ALL to ERROR
        '-Xms512m', -- Reduce initial heap size
        '-Xmx1g', -- Reduce max heap size from 2g to 1g
        -- Comprehensive JVM module and access control arguments
        '--add-modules=ALL-SYSTEM',
        '--enable-native-access=ALL-UNNAMED', -- Fix restricted method warnings
        -- Core Java base module opens
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang.reflect=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang.invoke=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.util.concurrent=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.util.concurrent.atomic=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.util.concurrent.locks=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.io=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.net=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.nio=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.nio.file=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.nio.charset=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.text=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.time=ALL-UNNAMED', -- Sun internal packages (fix Unsafe warnings)
        '--add-opens',
        'java.base/sun.misc=ALL-UNNAMED',
        '--add-opens',
        'java.base/sun.reflect=ALL-UNNAMED',
        '--add-opens',
        'java.base/sun.nio.ch=ALL-UNNAMED',
        '--add-opens',
        'java.base/sun.nio.fs=ALL-UNNAMED',
        '--add-opens',
        'java.base/sun.security.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/sun.security.ssl=ALL-UNNAMED',
        '--add-opens',
        'java.base/sun.security.x509=ALL-UNNAMED',
        '--add-opens',
        'java.base/sun.net.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/sun.net.www=ALL-UNNAMED', -- Desktop module opens
        '--add-opens',
        'java.desktop/java.awt=ALL-UNNAMED',
        '--add-opens',
        'java.desktop/java.awt.event=ALL-UNNAMED',
        '--add-opens',
        'java.desktop/java.awt.image=ALL-UNNAMED',
        '--add-opens',
        'java.desktop/javax.swing=ALL-UNNAMED',
        '--add-opens',
        'java.desktop/javax.swing.plaf=ALL-UNNAMED',
        '--add-opens',
        'java.desktop/sun.awt=ALL-UNNAMED',
        '--add-opens',
        'java.desktop/sun.swing=ALL-UNNAMED', -- Management and logging modules
        '--add-opens',
        'java.management/sun.management=ALL-UNNAMED',
        '--add-opens',
        'java.logging/java.util.logging=ALL-UNNAMED',

        -- Additional system properties to suppress warnings
        '-Djdk.incubator.vector.VECTOR_ACCESS_OOB_CHECK=0', -- Suppress incubator module warnings
        '-Djava.util.logging.config.file=', -- Disable default logging config
        '-Dlogback.configurationFile=', -- Disable logback auto-configuration
        '-Dorg.slf4j.simpleLogger.defaultLogLevel=ERROR', -- Set SLF4J to ERROR level
        '-Djdk.module.illegalAccess=permit', -- Allow illegal access (deprecated but helps)
        '-XX:+IgnoreUnrecognizedVMOptions', -- Ignore unrecognized VM options
        '-XX:-PrintGCDetails', -- Disable GC logging
        '-XX:-PrintGC', -- Disable GC logging
        '-Dsun.java2d.noddraw=true', -- Disable DirectDraw
        '-Dsun.awt.noerasebackground=true', -- Disable background erase
      }

      -- Add lombok agent if file exists
      if vim.fn.filereadable(paths.lombok) == 1 then table.insert(cmd, '-javaagent:' .. paths.lombok) end

      -- Add the remaining required arguments
      vim.list_extend(cmd, { '-jar', paths.launcher, '-configuration', paths.config, '-data', workspace_dir })

      -- Redirect stderr to suppress warnings (optional - comment out if you want to see all warnings)
      -- table.insert(cmd, "2>/dev/null")

      local config = {
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
        init_options = {
          bundles = bundles,
        },
        settings = {
          java = {
            -- IntelliJ IDEA-like completion settings
            completion = {
              enabled = true,
              maxResults = 50, -- Limit results for better performance
              favoriteStaticMembers = {
                'org.junit.Assert.*',
                'org.junit.Assume.*',
                'org.junit.jupiter.api.Assertions.*',
                'org.junit.jupiter.api.Assumptions.*',
                'org.junit.jupiter.api.DynamicContainer.*',
                'org.junit.jupiter.api.DynamicTest.*',
                'org.mockito.Mockito.*',
                'org.mockito.ArgumentMatchers.*',
                'org.mockito.Answers.*',
                'java.util.Objects.requireNonNull',
                'java.util.Objects.requireNonNullElse',
                'java.util.Objects.requireNonNullElseGet',
                'java.util.Collections.*',
                'java.util.stream.Collectors.*',
                'java.lang.System.*',
              },
              filteredTypes = {
                'com.sun.*',
                'sun.*',
                'jdk.internal.*',
                'org.graalvm.*',
                'io.micrometer.shaded.*',
              },
              importOrder = { 'java', 'javax', 'org', 'com', '' },
              guessMethodArguments = true,
              includeDecompiledSources = true,
              overwrite = false,
              -- IntelliJ-like completion preferences
              postfix = {
                enabled = false, -- Disable postfix completions for cleaner experience
              },
              chain = {
                enabled = true, -- Enable method chaining completions
              },
            },
            -- Content assist (auto-completion) settings
            contentAssist = {
              enabled = true,
              favoriteStaticMembers = {
                'org.junit.Assert.*',
                'org.junit.Assume.*',
                'org.junit.jupiter.api.Assertions.*',
                'org.mockito.Mockito.*',
                'java.util.Objects.requireNonNull',
                'java.util.Collections.*',
                'java.util.stream.Collectors.*',
                'java.lang.System.*',
              },
            },
            -- Signature help settings
            signatureHelp = {
              enabled = true,
              description = {
                enabled = true,
              },
            },
            -- Import settings for better organization
            imports = {
              gradle = {
                enabled = true,
              },
              maven = {
                enabled = true,
              },
              includeDecompiledSources = true,
            },
            -- Enhanced source actions
            sources = {
              organizeImports = {
                starThreshold = 99,
                staticStarThreshold = 99,
              },
            },
            configuration = {
              updateBuildConfiguration = 'automatic',
              -- Configure source path when no project files are found
              sourcePaths = { '.', 'src', 'src/main/java', 'app/src/main/java', 'java' },
              runtimes = {
                {
                  name = 'JavaSE-1.8',
                  path = '/usr/lib/jvm/java-8-openjdk',
                  default = true,
                },
                {
                  name = 'JavaSE-11',
                  path = '/usr/lib/jvm/java-11-openjdk',
                },
                {
                  name = 'JavaSE-17',
                  path = '/usr/lib/jvm/java-17-openjdk',
                },
                {
                  name = 'JavaSE-21',
                  path = '/usr/lib/jvm/java-21-openjdk',
                },
                {
                  name = 'JavaSE-24',
                  path = '/usr/lib/jvm/java-24-openjdk',
                },
              },
            },
            eclipse = {
              downloadSources = true,
            },
            format = {
              enabled = true,
              settings = {
                url = 'https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml',
                profile = 'GoogleStyle',
              },
            },
            project = {
              sourcePaths = { 'src', 'app/src' },
              referencedLibraries = {
                'lib/**/*.jar',
                'build/libs/**/*.jar',
                'app/build/libs/**/*.jar',
                '**/build/libs/**/*.jar',
              },
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            contentProvider = {
              preferred = 'fernflower',
            },
            completion = {
              favoriteStaticMembers = {
                'org.hamcrest.MatcherAssert.assertThat',
                'org.hamcrest.Matchers.*',
                'org.hamcrest.CoreMatchers.*',
                'org.junit.jupiter.api.Assertions.*',
                'java.util.Objects.requireNonNull',
                'java.util.Objects.requireNonNullElse',
                'org.mockito.Mockito.*',
              },
              filteredTypes = { 'com.sun.*', 'io.micrometer.shaded.*', 'java.awt.*', 'jdk.*', 'sun.*' },
              importOrder = { 'java', 'javax', 'com', 'org' },
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            codeGeneration = {
              toString = {
                template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
              },
              useBlocks = true,
            },
            gradle = {
              enabled = true,
              wrapper = {
                enabled = true,
              },
              java = {
                home = '/usr/lib/jvm/java-8-openjdk',
              },
              offline = {
                enabled = false,
              },
              arguments = '--stacktrace',
              buildServer = {
                enabled = true,
              },
              annotationProcessing = {
                enabled = true,
              },
              validation = {
                enabled = true,
                async = true,
              },
              projectSynchronization = {
                enabled = true,
              },
            },
          },
        },
        on_attach = function(client, bufnr)
          -- Regular on_attach from your handlers
          handlers.on_attach(client, bufnr)

          -- Force workspace symbol indexing for better search results
          vim.defer_fn(function()
            if client.server_capabilities.workspaceSymbolProvider then
              -- Trigger initial workspace symbol indexing
              vim.lsp.buf.workspace_symbol('')
            end
          end, 2000) -- Wait 2 seconds after server is ready

          -- jdtls-specific keymaps
          if jdtls.organize_imports then
            vim.keymap.set('n', '<leader>jo', jdtls.organize_imports, {
              buffer = bufnr,
              desc = 'Organize Imports',
            })
          end

          if jdtls.test_class then
            vim.keymap.set('n', '<leader>jt', jdtls.test_class, {
              buffer = bufnr,
              desc = 'Test Class',
            })
          end

          if jdtls.test_nearest_method then
            vim.keymap.set('n', '<leader>jn', jdtls.test_nearest_method, {
              buffer = bufnr,
              desc = 'Test Nearest Method',
            })
          end

          if jdtls.generate_to_string then
            vim.keymap.set('n', '<leader>jcg', jdtls.generate_to_string, {
              buffer = bufnr,
              desc = 'Generate toString',
            })
          end

          if jdtls.extract_variable then
            vim.keymap.set('n', '<leader>jce', jdtls.extract_variable, {
              buffer = bufnr,
              desc = 'Extract Variable',
            })
            vim.keymap.set('v', '<leader>jce', function() jdtls.extract_variable(true) end, {
              buffer = bufnr,
              desc = 'Extract Variable',
            })
          end

          if jdtls.extract_constant then
            vim.keymap.set('n', '<leader>jcc', jdtls.extract_constant, {
              buffer = bufnr,
              desc = 'Extract Constant',
            })
            vim.keymap.set('v', '<leader>jcc', function() jdtls.extract_constant(true) end, {
              buffer = bufnr,
              desc = 'Extract Constant',
            })
          end

          if jdtls.extract_method then
            vim.keymap.set('v', '<leader>jcm', function() jdtls.extract_method(true) end, {
              buffer = bufnr,
              desc = 'Extract Method',
            })
          end

          -- Setup DAP
          if jdtls.setup_dap then
            print('JDTLS: Setting up DAP integration...')
            jdtls.setup_dap({
              hotcodereplace = 'auto',
            })

            -- Verify the adapter was set up correctly
            vim.defer_fn(function()
              local dap = require('dap')
              if dap.adapters.java then
                if type(dap.adapters.java) == 'function' then
                  print('JDTLS: DAP adapter is function-based (may be fallback)')
                else
                  print('JDTLS: DAP adapter configured successfully')
                end
              else
                print('JDTLS: Warning - DAP adapter not found after setup_dap()')
              end
            end, 1000)
          else
            print('JDTLS: setup_dap function not available')
          end
        end,
        init_options = {
          bundles = bundles,
          -- Enhanced initialization for better completion
          extendedClientCapabilities = {
            progressReportProvider = false,
            classFileContentsSupport = true,
            generateToStringPromptSupport = true,
            hashCodeEqualsPromptSupport = true,
            advancedExtractRefactoringSupport = true,
            advancedOrganizeImportsSupport = true,
            generateConstructorsPromptSupport = true,
            generateDelegateMethodsPromptSupport = true,
            moveRefactoringSupport = true,
            overrideMethodsPromptSupport = true,
            executeClientCommandSupport = true,
            workspaceSymbolProvider = true,
            -- Enable better completion resolution
            resolveAdditionalTextEditsSupport = true,
          },
        },
        handlers = custom_handlers, -- Add custom handlers to suppress notifications
      }

      -- Start the server
      jdtls.start_or_attach(config)
    end

    -- Attach the LSP to Java files when they are opened
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'java' },
      callback = jdtls_setup,
      desc = 'Setup JDTLS for Java files',
    })

    -- Note: JDTLS commands are now defined in commands.lua

    -- Ensure JDTLS attaches to existing Java buffers
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'java' then
            jdtls_setup({
              buf = buf,
            })
          end
        end
      end,
      desc = 'Setup JDTLS for existing Java buffers',
    })
  end,
}
