-- ESLint LSP server configuration
return {
  settings = {
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = 'separateLine',
      },
      showDocumentation = {
        enable = true,
      },
    },
    codeActionOnSave = {
      enable = false,
      mode = 'all',
    },
    experimental = {
      useFlatConfig = true,
    },
    format = true,
    onIgnoredFiles = 'off',
    packageManager = 'npm',
    problems = {
      shortenToSingleLine = false,
    },
    quiet = false,
    rulesCustomizations = {},
    run = 'onType',
    useESLintClass = false,
    validate = 'on',
    workingDirectory = {
      mode = 'workspace',
    },
  },
  init_options = {
    typescript = {
      tsdk = vim.fn.stdpath('data') .. '/mason/packages/vtsls/node_modules/typescript/lib',
    },
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
    'svelte',
    'astro',
  },
  root_dir = function(fname)
    fname = tostring(fname)
    local util = require('lspconfig.util')
    local root = util.root_pattern(
      '.eslintrc',
      '.eslintrc.js',
      '.eslintrc.cjs',
      '.eslintrc.yaml',
      '.eslintrc.yml',
      '.eslintrc.json',
      'eslint.config.js',
      'eslint.config.mjs',
      'eslint.config.cjs',
      'package.json'
    )(fname)
    return root or util.path.dirname(fname)
  end,
  single_file_support = true,
  -- Start automatically to enable LSP formatting
  autostart = true,
}
