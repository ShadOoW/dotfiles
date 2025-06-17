-- yanky.nvim: Improved yank and put functionality
return {
  'gbprod/yanky.nvim',
  event = 'VeryLazy',
  dependencies = { 'ibhagwan/fzf-lua' },
  config = function()
    -- Basic yanky setup without telescope-specific options
    require('yanky').setup({
      ring = {
        history_length = 100,
        storage = 'memory',
        sync_with_numbered_registers = true,
        cancel_event = 'update',
      },
      picker = {
        select = {
          action = nil, -- Use default action
        },
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
      preserve_cursor_position = {
        enabled = true,
      },
    })

    -- Basic yanky mappings (these don't depend on telescope)
    vim.keymap.set({ 'n', 'x' }, 'y', '<Plug>(YankyYank)', {
      desc = 'Yank text',
    })
    vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)', {
      desc = 'Put after cursor',
    })
    vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)', {
      desc = 'Put before cursor',
    })
    vim.keymap.set('n', '<c-n>', '<Plug>(YankyCycleForward)', {
      desc = 'Cycle forward through yank history',
    })
    vim.keymap.set('n', '<c-p>', '<Plug>(YankyCycleBackward)', {
      desc = 'Cycle backward through yank history',
    })

    -- Add fzf-lua yank history picker
    vim.keymap.set('n', '<leader>zy', function()
      local yanky = require('yanky')
      local history = yanky.history()

      if vim.tbl_isempty(history) then
        vim.notify('Yank history is empty', vim.log.levels.INFO)
        return
      end

      local entries = {}
      for i, entry in ipairs(history) do
        local content = entry.regcontents[1] or ''
        -- Limit line length and show line count if multiline
        local display = content:gsub('\n', '\\n'):sub(1, 80)
        if #entry.regcontents > 1 then display = display .. string.format(' (%d lines)', #entry.regcontents) end
        table.insert(entries, string.format('%d: %s', i, display))
      end

      require('fzf-lua').fzf_exec(entries, {
        prompt = '󰄾 Yank History❯ ',
        winopts = {
          title = ' 󰄾 Yank History ',
          title_pos = 'center',
        },
        actions = {
          ['default'] = function(selected)
            if selected and #selected > 0 then
              local entry = selected[1]
              local index = tonumber(entry:match('^(%d+):'))
              if index and history[index] then
                yanky.put('p', {
                  regcontents = history[index].regcontents,
                })
              end
            end
          end,
        },
      })
    end, {
      desc = 'Yank History (fzf-lua)',
    })
  end,
}
