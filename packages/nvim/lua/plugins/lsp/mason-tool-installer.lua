return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  dependencies = { 'williamboman/mason.nvim' },
  config = function()
    require('mason-tool-installer').setup({
      ensure_installed = { -- LSP
        'jdtls', -- Java language server
        'java-debug-adapter', -- Java debugger
        'java-test', -- Java test runner
        'checkstyle', -- Java style checker
        'google-java-format', -- Java formatter
        'gradle-language-server', -- Gradle build tool support
        -- Linters
        'sonarlint-language-server', -- Advanced Java linting
        -- DAP
        'java-debug-adapter', -- Java debugging
        -- Formatters
        'google-java-format', -- Google Java format
      },
      auto_update = true,
      run_on_start = true,
    })
  end,
}
