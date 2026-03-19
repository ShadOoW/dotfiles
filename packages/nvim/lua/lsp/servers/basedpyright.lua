return {
  filetypes = { 'python' },
  settings = {
    basedpyright = {
      -- Let ruff handle import organisation; pyright's organizer conflicts with it.
      disableOrganizeImports = true,
      analysis = {
        typeCheckingMode = 'standard', -- off | basic | standard | strict | all
        autoImportCompletions = true,
        autoSearchPaths = true,
        -- Analyse the whole workspace, not just open files.
        diagnosticMode = 'workspace',
        useLibraryCodeForTypes = true,
        -- Silence diagnostics that ruff already covers so there are no duplicates.
        diagnosticSeverityOverrides = {
          reportUndefinedVariable = 'none', -- ruff F821
          reportUnusedImport = 'none',      -- ruff F401
          reportUnusedVariable = 'none',    -- ruff F841
        },
      },
    },
  },
}
