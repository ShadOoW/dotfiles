-- Modern VTSLS (Vue TypeScript Language Server) configuration
-- VTSLS is the successor to ts_ls with better performance and Vue support
return {
  cmd = { vim.fn.stdpath('data') .. '/mason/bin/vtsls', '--stdio' },
  settings = {
    vtsls = {
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
        -- Enable workspace-wide analysis
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
      -- Enable workspace symbol search across all files
      workspaceSymbols = {
        scope = 'workspace',
      },
    },
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'literal', -- 'none' | 'literals' | 'all'
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = false,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      preferences = {
        disableSuggestions = false,
        quotePreference = 'single',
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsWithInsertText = true,
        allowIncompleteCompletions = true,
        generateReturnInDocTemplate = true,
        includePackageJsonAutoImports = 'auto',
        useLabelDetailsInCompletionEntries = true,
      },
      suggest = {
        autoImports = true,
        completeFunctionCalls = false,
        completeJSDocs = true,
        enabled = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsForImportStatements = true,
        names = true,
        paths = true,
        objectLiteralMethodSnippets = {
          enabled = true,
        },
      },
      updateImportsOnFileMove = {
        enabled = 'always',
      },
      surveys = {
        enabled = false,
      },
      npm = {
        packageManager = 'auto',
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all'
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      preferences = {
        disableSuggestions = false,
        quotePreference = 'single',
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsWithInsertText = true,
        allowIncompleteCompletions = true,
        generateReturnInDocTemplate = true,
        includePackageJsonAutoImports = 'auto',
        useLabelDetailsInCompletionEntries = true,
      },
      suggest = {
        autoImports = true,
        completeFunctionCalls = false,
        completeJSDocs = true,
        enabled = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsForImportStatements = true,
        names = true,
        paths = true,
        objectLiteralMethodSnippets = {
          enabled = true,
        },
      },
      updateImportsOnFileMove = {
        enabled = 'always',
      },
      surveys = {
        enabled = false,
      },
      npm = {
        packageManager = 'auto',
      },
    },
    completions = {
      completeFunctionCalls = true,
    },
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
  },
  -- Ensure vtsls has higher priority for JavaScript/TypeScript files
  init_options = {
    hostInfo = 'neovim',
    maxTsServerMemory = 8192,
    typescript = {
      tsdk = vim.fn.stdpath('data') .. '/mason/packages/vtsls/node_modules/@vtsls/language-server/node_modules/typescript/lib',
    },
    preferences = {
      disableSuggestions = false,
    },
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = '', -- Will be automatically detected
        languages = { 'vue' },
      },
    },
  },
  single_file_support = true,
  root_dir = function(fname)
    local util = require('lspconfig.util')
    local root = util.root_pattern('tsconfig.json', 'package.json', 'jsconfig.json', '.git')(fname)
    if root then return root end
    -- Fallback to file directory for better single-file support
    local dir = util.path.dirname(fname)
    if dir and dir ~= '' then return dir end
    return vim.uv.cwd() or vim.fn.getcwd()
  end,
}
