-- Biome LSP server configuration
-- Modern alternative to ESLint + Prettier with better performance
return {
  settings = {
    biome = {
      -- Enable all features
      enabled = true,
      -- Linting configuration
      linter = {
        enabled = true,
        rules = {
          -- Enable recommended rules
          recommended = true,
          -- Modern JavaScript/TypeScript rules
          correctness = {
            -- Enable strict correctness checks
            noUnusedVariables = 'error',
            noUnusedImports = 'error',
            noUndeclaredVariables = 'error',
            useExhaustiveDependencies = 'warn',
          },
          style = {
            -- Code style preferences
            useConst = 'error',
            useTemplate = 'warn',
            noNegationElse = 'warn',
            useShorthandPropertyAssignment = 'warn',
          },
          suspicious = {
            -- Catch suspicious patterns
            noExplicitAny = 'warn',
            noArrayIndexKey = 'warn',
            noAsyncPromiseExecutor = 'error',
          },
          performance = {
            -- Performance optimizations
            noAccumulatingSpread = 'warn',
            noDelete = 'error',
          },
          complexity = {
            -- Complexity management
            noExtraBooleanCast = 'error',
            noMultipleSpacesInRegularExpressionLiterals = 'error',
            noStaticOnlyClass = 'error',
            noUselessCatch = 'error',
            noUselessConstructor = 'error',
            noUselessFragments = 'error',
            noUselessLabel = 'error',
            noUselessRename = 'error',
            noVoid = 'error',
            noWith = 'error',
            useLiteralKeys = 'error',
            useOptionalChain = 'warn',
          },
        },
      },
      -- Formatting configuration
      formatter = {
        enabled = true,
        formatOnSave = true,
        indentStyle = 'space',
        indentSize = 2,
        lineWidth = 120,
        -- Quote preferences
        quoteStyle = 'single',
        jsxQuoteStyle = 'double',
        quoteProperties = 'asNeeded',
        -- Trailing commas
        trailingComma = 'es5',
        -- Semicolons
        semicolons = 'always',
        -- Arrow parentheses
        arrowParentheses = 'asNeeded',
        -- Bracket spacing
        bracketSpacing = true,
        bracketSameLine = false,
      },
      -- Organize imports
      organizeImports = {
        enabled = true,
      },
    },
  },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'json', 'jsonc' },
  root_dir = function(fname)
    return require('lspconfig.util').root_pattern('biome.json', 'biome.jsonc', 'package.json', '.git')(fname)
  end,
  single_file_support = true,
  init_options = {
    -- Enable all features
    lintRules = {
      recommended = true,
    },
  },
}
