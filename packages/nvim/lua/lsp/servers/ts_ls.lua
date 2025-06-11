-- TypeScript/JavaScript LSP server configuration
return {
  settings = {
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
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
  init_options = {
    hostInfo = 'neovim',
    maxTsServerMemory = 8192,
    typescript = {
      tsdk = vim.fn.stdpath('data') .. '/mason/packages/typescript-language-server/node_modules/typescript/lib',
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
    return require('lspconfig.util').root_pattern('tsconfig.json', 'package.json', 'jsconfig.json', '.git')(fname)
  end,
}
