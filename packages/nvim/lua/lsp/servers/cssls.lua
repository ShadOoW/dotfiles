-- CSS LSP server configuration
return {
  settings = {
    css = {
      validate = true,
      format = {
        enable = true,
      },
      hover = {
        documentation = true,
        references = true,
      },
      completion = {
        completePropertyWithSemicolon = true,
        triggerPropertyValueCompletion = true,
      },
      lint = {
        compatibleVendorPrefixes = 'ignore',
        vendorPrefix = 'warning',
        duplicateProperties = 'warning',
        emptyRules = 'warning',
        importStatement = 'ignore',
        boxModel = 'ignore',
        universalSelector = 'ignore',
        zeroUnits = 'ignore',
        fontFaceProperties = 'warning',
        hexColorLength = 'error',
        argumentsInColorFunction = 'error',
        unknownProperties = 'warning',
        ieHack = 'ignore',
        unknownVendorSpecificProperties = 'ignore',
        propertyIgnoredDueToDisplay = 'warning',
        important = 'ignore',
        float = 'ignore',
        idSelector = 'ignore',
      },
    },
    scss = {
      validate = true,
      format = {
        enable = true,
      },
      hover = {
        documentation = true,
        references = true,
      },
      completion = {
        completePropertyWithSemicolon = true,
        triggerPropertyValueCompletion = true,
      },
      lint = {
        compatibleVendorPrefixes = 'ignore',
        vendorPrefix = 'warning',
        duplicateProperties = 'warning',
        emptyRules = 'warning',
        importStatement = 'ignore',
        boxModel = 'ignore',
        universalSelector = 'ignore',
        zeroUnits = 'ignore',
        fontFaceProperties = 'warning',
        hexColorLength = 'error',
        argumentsInColorFunction = 'error',
        unknownProperties = 'warning',
        ieHack = 'ignore',
        unknownVendorSpecificProperties = 'ignore',
        propertyIgnoredDueToDisplay = 'warning',
        important = 'ignore',
        float = 'ignore',
        idSelector = 'ignore',
      },
    },
    less = {
      validate = true,
      format = {
        enable = true,
      },
      hover = {
        documentation = true,
        references = true,
      },
      completion = {
        completePropertyWithSemicolon = true,
        triggerPropertyValueCompletion = true,
      },
      lint = {
        compatibleVendorPrefixes = 'ignore',
        vendorPrefix = 'warning',
        duplicateProperties = 'warning',
        emptyRules = 'warning',
        importStatement = 'ignore',
        boxModel = 'ignore',
        universalSelector = 'ignore',
        zeroUnits = 'ignore',
        fontFaceProperties = 'warning',
        hexColorLength = 'error',
        argumentsInColorFunction = 'error',
        unknownProperties = 'warning',
        ieHack = 'ignore',
        unknownVendorSpecificProperties = 'ignore',
        propertyIgnoredDueToDisplay = 'warning',
        important = 'ignore',
        float = 'ignore',
        idSelector = 'ignore',
      },
    },
  },
  filetypes = { 'css', 'scss', 'less' },
  init_options = {
    provideFormatter = true,
  },
  -- CSS language server for pure CSS files only
  root_dir = function(fname)
    return require('lspconfig.util').root_pattern(
      '.git',
      'package.json',
      'node_modules',
      'style.css',
      'styles.css',
      'main.css',
      '.cssrc',
      '.cssrc.json'
    )(fname) or vim.fn.getcwd()
  end,
  single_file_support = true,
}
