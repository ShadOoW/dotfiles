-- Enhanced cursorline with safer implementation
return {
  'RRethy/vim-illuminate',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('illuminate').configure({
      providers = { 'lsp', 'treesitter', 'regex' },
      delay = 120,
      filetype_overrides = {},
      filetypes_denylist = {
        'dirvish',
        'fugitive',
        'alpha',
        'NvimTree',
        'lazy',
        'neogitstatus',
        'Trouble',
        'lir',
        'Outline',
        'spectre_panel',
        'DressingSelect',
        'TelescopePrompt',
      },
      filetypes_allowlist = {},
      modes_denylist = {},
      modes_allowlist = {},
      providers_regex_syntax_denylist = {},
      providers_regex_syntax_allowlist = {},
      under_cursor = true,
      large_file_cutoff = nil,
      large_file_overrides = nil,
      min_count_to_highlight = 1,
    })

    -- Set custom highlight for illuminated words
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        vim.api.nvim_set_hl(0, 'IlluminatedWordText', {
          underline = true,
          sp = '#7aa2f7',
        })
        vim.api.nvim_set_hl(0, 'IlluminatedWordRead', {
          underline = true,
          sp = '#7aa2f7',
        })
        vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', {
          underline = true,
          sp = '#e0af68',
        })
      end,
      desc = 'Update Illuminate highlights after colorscheme change',
    })

    -- Apply immediately
    vim.api.nvim_set_hl(0, 'IlluminatedWordText', {
      underline = true,
      sp = '#7aa2f7',
    })
    vim.api.nvim_set_hl(0, 'IlluminatedWordRead', {
      underline = true,
      sp = '#7aa2f7',
    })
    vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', {
      underline = true,
      sp = '#e0af68',
    })
  end,
}
