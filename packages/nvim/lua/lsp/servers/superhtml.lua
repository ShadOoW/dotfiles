-- SuperHTML LSP server configuration
-- First HTML LSP that reports syntax errors properly
-- https://kristoff.it/blog/first-html-lsp/
--
-- IMPORTANT: SuperHTML automatically follows HTML5 standards:
-- ✓ Void elements (br, img, input, etc.) are NOT self-closed (no "/>" ending)
-- ✓ Proper HTML5 syntax validation
-- ✓ No custom settings needed - works out of the box
--
-- To use SuperHTML formatting exclusively:
-- 1. :Html5Format - format current HTML file with SuperHTML only
-- 2. :Html5Test - test SuperHTML installation and see examples
-- 3. conform.nvim is configured to use SuperHTML only for HTML files
return {
  -- SuperHTML doesn't use traditional LSP settings structure
  -- It formats according to HTML5 spec by default (no self-closing void elements)
  -- Autoformatter automatically handles proper HTML5 formatting
  filetypes = { 'html', 'htm', 'xhtml' },
  root_dir = function(fname)
    -- Try to find a project root, but fallback to file directory
    local project_root =
      require('lspconfig.util').root_pattern('.git', 'package.json', 'index.html', '.superhtml')(fname)
    if project_root then return project_root end
    -- Fallback: use the directory containing the HTML file
    return vim.fn.fnamemodify(fname, ':h')
  end,
  single_file_support = true,
}
