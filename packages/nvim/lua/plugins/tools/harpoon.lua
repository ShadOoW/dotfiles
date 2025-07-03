-- Harpoon - Quick file navigation
-- Modern file marking and navigation system
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require('harpoon')
    local keymap = require('utils.keymap')

    -- Setup harpoon with default configuration
    harpoon:setup({
      global_settings = {
        save_on_toggle = false,
        save_on_change = true,
        enter_on_sendcmd = false,
        tmux_autoclose_windows = false,
        excluded_filetypes = { 'harpoon', 'alpha', 'dashboard', 'gitcommit' },
        mark_branch = false,
        tabline = false,
      },
      projects = {
        -- Example per-project config
        -- ['~/work/project1'] = {
        --   save_on_toggle = true,
        -- }
      },
    })

    -- Key mappings with <leader>h prefix
    -- Add current file to harpoon list
    keymap.n('<leader>ha', function() harpoon:list():add() end, 'Add file to harpoon')

    -- Toggle quick menu
    keymap.n('<leader>hh', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, 'Toggle harpoon menu')

    -- Remove current file from harpoon list
    keymap.n('<leader>hr', function() harpoon:list():remove() end, 'Remove file from harpoon')

    -- Clear all harpoon marks
    keymap.n('<leader>hc', function() harpoon:list():clear() end, 'Clear all harpoon marks')

    -- Navigate to specific files by index (1-4 for quick access)
    keymap.n('<leader>h1', function() harpoon:list():select(1) end, 'Harpoon file 1')
    keymap.n('<leader>h2', function() harpoon:list():select(2) end, 'Harpoon file 2')
    keymap.n('<leader>h3', function() harpoon:list():select(3) end, 'Harpoon file 3')
    keymap.n('<leader>h4', function() harpoon:list():select(4) end, 'Harpoon file 4')

    -- Navigate through harpoon list
    keymap.n('<leader>hp', function() harpoon:list():prev() end, 'Previous harpoon file')
    keymap.n('<leader>hn', function() harpoon:list():next() end, 'Next harpoon file')

    -- Alternative quick navigation with Alt + numbers (non-conflicting)
    keymap.n('<M-1>', function() harpoon:list():select(1) end, 'Harpoon file 1 (quick)')
    keymap.n('<M-2>', function() harpoon:list():select(2) end, 'Harpoon file 2 (quick)')
    keymap.n('<M-3>', function() harpoon:list():select(3) end, 'Harpoon file 3 (quick)')
    keymap.n('<M-4>', function() harpoon:list():select(4) end, 'Harpoon file 4 (quick)')

    -- Integration with fzf-lua for enhanced file selection
    keymap.n('<leader>hS', function()
      local items = {}
      local list = harpoon:list()
      for i = 1, list:length() do
        local item = list:get(i)
        if item and item.value then
          table.insert(items, {
            text = vim.fn.fnamemodify(item.value, ':t'),
            file = item.value,
            idx = i,
          })
        end
      end

      if #items == 0 then
        require('utils.notify').warn('Harpoon', 'No files in harpoon list')
        return
      end

      local fzf = require('fzf-lua')
      fzf.fzf_exec(function(cb)
        for _, item in ipairs(items) do
          cb(item.text .. '\t' .. item.file .. '\t' .. item.idx)
        end
      end, {
        prompt = '󰛢 Harpoon Files: ',
        actions = {
          ['default'] = function(selected)
            if not selected[1] then return end
            local parts = vim.split(selected[1], '\t')
            local idx = tonumber(parts[3])
            if idx then harpoon:list():select(idx) end
          end,
        },
        winopts = {
          title = '󰛢 Harpoon Files',
          preview = {
            hidden = 'hidden',
          },
        },
      })
    end, 'Harpoon files (picker)')

    -- Visual indicators in status line (optional integration with lualine)
    vim.api.nvim_create_user_command('HarpoonStatus', function()
      local list = harpoon:list()
      local current_file = vim.api.nvim_buf_get_name(0)

      print('Harpoon Status:')
      for i = 1, list:length() do
        local item = list:get(i)
        if item and item.value then
          local marker = (item.value == current_file) and '→ ' or '  '
          print(string.format('%s%d: %s', marker, i, vim.fn.fnamemodify(item.value, ':t')))
        end
      end
    end, {
      desc = 'Show harpoon status',
    })
  end,
}
