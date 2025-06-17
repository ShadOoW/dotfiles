-- UFO - Ultra Fold in Neovim with modern folding features
return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async', 'nvim-treesitter/nvim-treesitter' },
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    -- Set fold options
    vim.o.foldcolumn = '1' -- Show fold column
    vim.o.foldlevel = 99 -- High fold level for UFO
    vim.o.foldlevelstart = 99 -- Start with all folds open
    vim.o.foldenable = true -- Enable folding

    -- Use treesitter as fold provider with LSP fallback
    require('ufo').setup({
      provider_selector = function(bufnr, filetype, buftype) return { 'treesitter', 'indent' } end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0

        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end

        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end,
      open_fold_hl_timeout = 150,
      close_fold_kinds = { 'imports', 'comment' },
      preview = {
        win_config = {
          border = { '', '─', '', '', '', '─', '', '' },
          winhighlight = 'Normal:Folded',
          winblend = 0,
        },
        mappings = {
          scrollU = '<C-u>',
          scrollD = '<C-d>',
          jumpTop = '[',
          jumpBot = ']',
        },
      },
    })

    -- Custom keymaps for folding
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds, {
      desc = 'Open all folds',
    })
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, {
      desc = 'Close all folds',
    })
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, {
      desc = 'Open folds except kinds',
    })
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, {
      desc = 'Close folds with',
    })

    -- Peek fold
    vim.keymap.set('n', 'K', function()
      local winid = require('ufo').peekFoldedLinesUnderCursor()
      if not winid then vim.lsp.buf.hover() end
    end, {
      desc = 'Peek Fold / LSP Hover',
    })
  end,
}
