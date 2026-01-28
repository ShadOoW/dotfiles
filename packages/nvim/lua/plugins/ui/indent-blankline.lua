-- Subtle indentation guides with minimal scope highlighting
return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    -- Subtle highlight groups for indent guides
    local indent_highlight = { 'IBLIndent1', 'IBLIndent2', 'IBLIndent3' }

    -- Very subtle scope highlight
    local scope_highlight = 'IBLScope'

    local hooks = require('ibl.hooks')
    -- Create subtle highlight groups
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      -- Subtle indent guides - very faint
      vim.api.nvim_set_hl(0, 'IBLIndent1', {
        fg = '#2a2e36',
      })
      vim.api.nvim_set_hl(0, 'IBLIndent2', {
        fg = '#2d3139',
      })
      vim.api.nvim_set_hl(0, 'IBLIndent3', {
        fg = '#30343c',
      })

      -- Subtle scope highlighting - slightly more visible but not distracting
      vim.api.nvim_set_hl(0, 'IBLScope', {
        fg = '#414868',
      })
    end)

    require('ibl').setup({
      indent = {
        char = '│', -- Thinner character
        tab_char = '│',
        highlight = indent_highlight,
        smart_indent_cap = true,
        priority = 1, -- Lower priority
      },
      whitespace = {
        remove_blankline_trail = true,
      },
      scope = {
        enabled = true,
        show_start = false, -- Don't show start line
        show_end = false, -- Don't show end line
        injected_languages = false,
        highlight = scope_highlight,
        priority = 100, -- Much lower priority than before
        include = {
          node_type = {
            ['*'] = {
              'function_definition',
              'function_declaration',
              'method_definition',
              'class_definition',
              'if_statement',
              'for_statement',
              'while_statement',
              'try_statement',
            },
          },
        },
      },
      exclude = {
        filetypes = {
          'lspinfo',
          'packer',
          'checkhealth',
          'help',
          'man',
          'gitcommit',
          'TelescopePrompt',
          'TelescopeResults',
          'lazy',
          'mason',
          'trouble',
          'neo-tree',
          'NvimTree',
          'startify',
          'Sidebar',
          'noice',
          'alpha',
          'dashboard',
          'Trouble',
          'lir',
          'Outline',
          'spectre_panel',
          'DressingSelect',
          'tsplayground',
          'notify',
        },
        buftypes = { 'terminal', 'nofile', 'quickfix', 'prompt' },
      },
    })
  end,
}
