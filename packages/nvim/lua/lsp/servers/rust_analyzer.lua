return {
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = { enable = true },
      },
      -- Use clippy instead of cargo check for richer diagnostics.
      checkOnSave = true,
      check = {
        command = 'clippy',
        extraArgs = { '--no-deps' },
      },
      procMacro = {
        enable = true,
        -- Silence noisy proc-macro warnings from common async crates.
        ignored = {
          ['async-trait'] = { 'async_trait' },
          ['napi-derive'] = { 'napi' },
          ['async-recursion'] = { 'async_recursion' },
        },
      },
      rustfmt = {
        enable = true,
        rangeFormatting = { enable = true },
      },
      inlayHints = {
        bindingModeHints = { enable = true },
        chainingHints = { enable = true },
        closingBraceHints = { enable = true, minLines = 10 },
        closureReturnTypeHints = { enable = 'with_block' },
        lifetimeElisionHints = { enable = 'skip_trivial', useParameterNames = true },
        maxLength = { enable = true, length = 25 },
        parameterHints = { enable = true },
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
      diagnostics = {
        disabled = { 'unlinked-file' },
        experimental = { enable = true },
      },
      completion = {
        callable = { snippets = 'fill_arguments' },
        postfix = { enable = true },
      },
      imports = {
        granularity = { group = 'module' },
        prefix = 'self',
      },
      workspace = {
        symbol = { search = { kind = 'all_symbols' } },
      },
    },
  },

  -- Chain the global on_attach so inlay hints / doc highlights still apply,
  -- then add rust-specific keymaps.
  on_attach = function(client, bufnr)
    require('lsp.handlers').on_attach(client, bufnr)

    local function map(key, fn, desc) vim.keymap.set('n', key, fn, { buffer = bufnr, desc = 'Rust: ' .. desc }) end

    -- ── LSP / rust-analyzer workspace commands ───────────────────────────────
    map(
      '<leader>re',
      function() vim.lsp.buf.execute_command({ command = 'rust-analyzer.expandMacro' }) end,
      'Expand macro'
    )

    map(
      '<leader>rp',
      function() vim.lsp.buf.execute_command({ command = 'rust-analyzer.parentModule' }) end,
      'Go to parent module'
    )

    map(
      '<leader>ro',
      function() vim.lsp.buf.execute_command({ command = 'rust-analyzer.openDocs' }) end,
      'Open docs in browser'
    )

    map(
      '<leader>rj',
      function() vim.lsp.buf.execute_command({ command = 'rust-analyzer.joinLines' }) end,
      'Join lines (smart)'
    )

    map('<leader>rw', function()
      vim.lsp.buf.execute_command({ command = 'rust-analyzer.reloadWorkspace' })
      require('utils.notify').info('Rust', 'Workspace reloaded')
    end, 'Reload workspace')

    -- ── Cargo commands in a horizontal terminal split ────────────────────────
    local root = client.config.root_dir or vim.fn.getcwd()

    local function cargo(subcmd, desc)
      map(
        '<leader>r' .. subcmd:sub(1, 1),
        function() require('toggleterm').exec('cargo ' .. subcmd, 1, 15, root, 'horizontal') end,
        'cargo ' .. desc
      )
    end

    cargo('run', 'run')
    cargo('test', 'test')
    cargo('build', 'build')
    -- clippy uses <leader>rk (k for check+clippy, c is taken by 'cargo check')
    map(
      '<leader>rk',
      function() require('toggleterm').exec('cargo clippy --all-targets --all-features', 1, 15, root, 'horizontal') end,
      'cargo clippy'
    )
  end,
}
