return {
    "mfussenegger/nvim-jdtls",
    dependencies = {"neovim/nvim-lspconfig"},
    ft = {"java"},
    config = function()
        local jdtls = require("jdtls")
        local handlers = require("lsp.handlers")

        -- Find root directory based on maven or gradle files or source directories
        local root_markers = {".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle", ".classpath",
                              ".project", "src/main/java", -- Standard Maven/Gradle layout
        "src", -- Simple project layout
        "java" -- Even simpler layout
        }

        local function get_jdtls_paths()
            local path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
            local path_to_config = path .. "/config_linux"
            local path_to_plugins = path .. "/plugins"
            local path_to_jar = vim.fn.glob(path_to_plugins .. "/org.eclipse.equinox.launcher_*.jar")

            return {
                java_path = "/usr/lib/jvm/java-24-openjdk/bin/java",
                launcher = path_to_jar,
                config = path_to_config,
                plugins = path_to_plugins
            }
        end

        local function jdtls_setup(event)
            local paths = get_jdtls_paths()
            -- Try to find a project root
            local root_dir = require("jdtls.setup").find_root(root_markers)

            -- If no root found or if it's empty, use the current working directory
            if not root_dir or root_dir == "" then
                root_dir = vim.fn.getcwd()
                print("JDTLS: No project root found, using current directory: " .. root_dir)
            else
                print("JDTLS: Using project root: " .. root_dir)
            end

            -- Create data directory for each project
            local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
            local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

            -- Make sure the directory exists
            vim.fn.mkdir(workspace_dir, "p")

            -- Get the capabilities and adjust as needed for completion
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Main config
            local config = {
                cmd = {paths.java_path, -- Path to Java executable
                "-Declipse.application=org.eclipse.jdt.ls.core.id1", "-Dosgi.bundles.defaultStartLevel=4",
                       "-Declipse.product=org.eclipse.jdt.ls.core.product", "-Dlog.protocol=true", "-Dlog.level=ALL",
                       "-Xmx2g", "--add-modules=ALL-SYSTEM", "--enable-native-access=ALL-UNNAMED", "--add-opens",
                       "java.base/java.util=ALL-UNNAMED", "--add-opens", "java.base/java.lang=ALL-UNNAMED", "-jar",
                       paths.launcher, "-configuration", paths.config, "-data", workspace_dir},
                root_dir = root_dir,
                capabilities = capabilities,
                settings = {
                    java = {
                        configuration = {
                            updateBuildConfiguration = "interactive",
                            -- Configure source path when no project files are found
                            -- This helps with working directory only projects
                            sourcePaths = {".", "src", "src/main/java", "java"},
                            runtimes = {{
                                name = "JavaSE-1.8",
                                path = "/usr/lib/jvm/java-8-openjdk",
                                default = true
                            }, {
                                name = "JavaSE-24",
                                path = "/usr/lib/jvm/java-24-openjdk"
                            }}
                        },
                        eclipse = {
                            downloadSources = true
                        },
                        format = {
                            enabled = true,
                            settings = {
                                url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
                                profile = "GoogleStyle"
                            }
                        },
                        project = {
                            sourcePaths = {"src"}
                        },
                        maven = {
                            downloadSources = true
                        },
                        implementationsCodeLens = {
                            enabled = true
                        },
                        referencesCodeLens = {
                            enabled = true
                        },
                        references = {
                            includeDecompiledSources = true
                        },
                        signatureHelp = {
                            enabled = true
                        },
                        contentProvider = {
                            preferred = "fernflower"
                        },
                        completion = {
                            favoriteStaticMembers = {"org.hamcrest.MatcherAssert.assertThat", "org.hamcrest.Matchers.*",
                                                     "org.hamcrest.CoreMatchers.*",
                                                     "org.junit.jupiter.api.Assertions.*",
                                                     "java.util.Objects.requireNonNull",
                                                     "java.util.Objects.requireNonNullElse", "org.mockito.Mockito.*"},
                            filteredTypes = {"com.sun.*", "io.micrometer.shaded.*", "java.awt.*", "jdk.*", "sun.*"}
                        },
                        sources = {
                            organizeImports = {
                                starThreshold = 9999,
                                staticStarThreshold = 9999
                            }
                        },
                        codeGeneration = {
                            toString = {
                                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                            },
                            useBlocks = true
                        }
                    }
                },
                on_attach = function(client, bufnr)
                    -- Regular on_attach from your handlers
                    handlers.on_attach(client, bufnr)

                    -- jdtls-specific keymaps (check for nil functions first)
                    if jdtls.organize_imports then
                        vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, {
                            buffer = bufnr,
                            desc = "Organize Imports"
                        })
                    end

                    if jdtls.test_class then
                        vim.keymap.set("n", "<leader>jt", jdtls.test_class, {
                            buffer = bufnr,
                            desc = "Test Class"
                        })
                    end

                    if jdtls.test_nearest_method then
                        vim.keymap.set("n", "<leader>jn", jdtls.test_nearest_method, {
                            buffer = bufnr,
                            desc = "Test Nearest Method"
                        })
                    end

                    if jdtls.generate_to_string then
                        vim.keymap.set("n", "<leader>jcg", jdtls.generate_to_string, {
                            buffer = bufnr,
                            desc = "Generate toString"
                        })
                    end

                    if jdtls.extract_variable then
                        vim.keymap.set("n", "<leader>jce", jdtls.extract_variable, {
                            buffer = bufnr,
                            desc = "Extract Variable"
                        })

                        vim.keymap.set("v", "<leader>jce", function()
                            jdtls.extract_variable(true)
                        end, {
                            buffer = bufnr,
                            desc = "Extract Variable"
                        })
                    end

                    if jdtls.extract_constant then
                        vim.keymap.set("n", "<leader>jcc", jdtls.extract_constant, {
                            buffer = bufnr,
                            desc = "Extract Constant"
                        })

                        vim.keymap.set("v", "<leader>jcc", function()
                            jdtls.extract_constant(true)
                        end, {
                            buffer = bufnr,
                            desc = "Extract Constant"
                        })
                    end

                    if jdtls.extract_method then
                        vim.keymap.set("v", "<leader>jcm", function()
                            jdtls.extract_method(true)
                        end, {
                            buffer = bufnr,
                            desc = "Extract Method"
                        })
                    end

                    -- If DAP is installed, add this only if setup_dap exists
                    if jdtls.setup_dap then
                        jdtls.setup_dap({
                            hotcodereplace = "auto"
                        })
                    end
                end,
                init_options = {
                    bundles = {} -- Will be extended with bundles from java-debug and vscode-java-test
                }
            }

            -- Start the server
            jdtls.start_or_attach(config)
        end

        -- Attach the LSP to Java files when they are opened
        vim.api.nvim_create_autocmd("FileType", {
            pattern = {"java"},
            callback = jdtls_setup
        })
    end
}
