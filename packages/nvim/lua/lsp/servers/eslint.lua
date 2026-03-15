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
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'svelte',
    'astro',
  },
  root_dir = function(fname)
    -- Handle case where fname is not provided
    if not fname or type(fname) ~= 'string' then return nil end
    -- Use vim.fs.find to look for eslint config files
    local found = vim.fs.find({
      '.eslintrc',
      '.eslintrc.js',
      '.eslintrc.cjs',
      '.eslintrc.yaml',
      '.eslintrc.yml',
      '.eslintrc.json',
      'eslint.config.js',
      'eslint.config.mjs',
      'eslint.config.cjs',
      'package.json',
    }, { upward = true, path = vim.fs.dirname(fname) })[1]
    return found and vim.fs.dirname(found)
  end,
  single_file_support = false,
  workspace_required = true,
}
