-- Rust Analyzer LSP server configuration
-- Simple, clean setup following best practices
return {
  settings = {
    ['rust-analyzer'] = {
      -- Cargo configuration
      cargo = {
        allFeatures = true,
        checkOnSave = {
          command = 'check',
        },
      },
      -- Enable rustfmt for formatting
      rustfmt = {
        enable = true,
      },
      -- Inlay hints
      inlayHints = {
        parameterHints = { enable = true },
        typeHints = { enable = true },
      },
      -- Diagnostics configuration
      diagnostics = {
        -- Disable unlinked-file warning for standalone Rust files
        disabled = { 'unlinked-file' },
      },
    },
  },
}
