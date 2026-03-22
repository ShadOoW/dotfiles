-- LSP guard: enforces filetype rules, warns on missing servers, detects mason orphans.
local M = {}

-- Track buffers where we've already checked for missing servers (reset on wipeout).
local checked_bufs = {}

function M.setup()
  local server_list = require('lsp.servers-list')

  -- 1. On LspAttach: immediately stop any server listed as forbidden for this filetype.
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      -- Never attach LSP to virtual diffview:// buffers — their paths don't exist
      -- on disk and are not in any tsconfig, causing spurious ESLint/tsserver errors.
      local bufname = vim.api.nvim_buf_get_name(args.buf)
      if bufname:match('^diffview://') then
        vim.lsp.stop_client(client.id, true)
        return
      end

      local ft = vim.bo[args.buf].filetype
      local rules = server_list.filetype_rules[ft]
      if not rules then return end
      if vim.tbl_contains(rules.forbidden or {}, client.name) then
        require('utils.notify').warn(
          'LSP Guard',
          ('Stopped forbidden server "%s" on %s filetype'):format(client.name, ft)
        )
        vim.lsp.stop_client(client.id, true)
      end
    end,
    desc = 'LSP Guard: stop forbidden servers on attach',
  })

  -- 2. On BufEnter (after a settle period): warn once per buffer if expected servers are absent.
  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function(args)
      local bufnr = args.buf
      if checked_bufs[bufnr] then return end
      -- Set immediately so re-entering the same buffer within the settle window
      -- doesn't queue duplicate deferred checks.
      checked_bufs[bufnr] = true
      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(bufnr) then return end
        local ft = vim.bo[bufnr].filetype
        local rules = server_list.filetype_rules[ft]
        if not rules or not rules.expected or #rules.expected == 0 then return end

        local attached_names = vim.tbl_map(
          function(c) return c.name end,
          vim.lsp.get_clients({ bufnr = bufnr })
        )
        local missing = vim.tbl_filter(
          function(s) return not vim.tbl_contains(attached_names, s) end,
          rules.expected
        )
        if #missing > 0 then
          require('utils.notify').warn(
            'LSP Guard',
            ('Expected server(s) not attached for %s: %s'):format(ft, table.concat(missing, ', '))
          )
        end
      end, 3000)
    end,
    desc = 'LSP Guard: warn when expected servers are absent',
  })

  -- Reset per-buffer check cache when the buffer is wiped.
  vim.api.nvim_create_autocmd('BufWipeout', {
    callback = function(args) checked_bufs[args.buf] = nil end,
  })

  -- 3. On startup (delayed): detect LSP-related mason packages that are installed but
  --    not in our server list — these are the cause of "ghost" servers reappearing.
  vim.defer_fn(M.check_mason_orphans, 6000)
end

-- Also callable manually via :LspCheckOrphans.
function M.check_mason_orphans()
  local ok_reg, registry = pcall(require, 'mason-registry')
  if not ok_reg then return end
  local ok_map, mappings = pcall(require, 'mason-lspconfig.mappings')
  if not ok_map then return end

  local server_list = require('lsp.servers-list')
  local allowed = {}
  for _, s in ipairs(server_list.servers) do
    allowed[s] = true
  end

  local pkg_to_lsp = mappings.get_mason_map().package_to_lspconfig
  local orphans = {}
  for _, pkg in ipairs(registry.get_installed_package_names()) do
    local lsp_name = pkg_to_lsp[pkg]
    if lsp_name and not allowed[lsp_name] then
      table.insert(orphans, ('  %s  →  lsp: %s'):format(pkg, lsp_name))
    end
  end

  if #orphans > 0 then
    require('utils.notify').warn(
      'LSP Guard',
      'Orphaned mason LSP packages (installed but not in server list):\n'
        .. table.concat(orphans, '\n')
        .. '\n\nRun  :MasonUninstall <package>  to remove'
    )
  end
end

return M
