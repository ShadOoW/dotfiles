-- Healthy Buffer Auto-Close (HBAC)
-- Automatically close unmodified buffers when the number gets too high
return {
  'axkirillov/hbac.nvim',
  event = 'VeryLazy',
  config = function()
    local hbac = require('hbac')

    -- Track buffers that have been modified
    local never_modified_buffers = {}

    -- Mark buffer as modified when entering insert mode or making changes
    local function track_buffer_modification()
      local bufnr = vim.api.nvim_get_current_buf()
      never_modified_buffers[bufnr] = false
    end

    -- Initialize tracking for new buffers
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
      callback = function(args)
        local bufnr = args.buf
        if never_modified_buffers[bufnr] == nil then
          never_modified_buffers[bufnr] = true -- Mark as never modified initially
        end
      end,
      desc = 'Initialize buffer modification tracking',
    })

    -- Track when buffers are modified
    vim.api.nvim_create_autocmd({ 'InsertEnter', 'TextChanged', 'TextChangedI' }, {
      callback = track_buffer_modification,
      desc = 'Track buffer modifications for HBAC',
    })

    -- Clean up tracking when buffers are deleted
    vim.api.nvim_create_autocmd('BufDelete', {
      callback = function(args) never_modified_buffers[args.buf] = nil end,
      desc = 'Clean up buffer modification tracking',
    })

    hbac.setup({
      -- Close buffers that haven't been viewed for this amount of time (in minutes)
      autoclose_if_unused_for = 30,

      -- Maximum number of unmodified buffers to keep
      threshold = 5,

      -- Never close these filetypes
      close_buffers_with_windows = false,

      -- Filetypes to ignore
      ignore_filetypes = {
        'help',
        'Trouble',
        'dashboard',
        'toggleterm',
        'DiffviewFiles',
        'DiffviewFileHistory',
        'qf',
        'TelescopePrompt',
        'TelescopeResults',
      },

      -- Buffer types to ignore
      ignore_buftypes = { 'help', 'nofile', 'quickfix', 'terminal', 'prompt' },

      -- Custom close command that respects our never-modified tracking
      close_command = function(bufnr)
        -- Don't close buffers in command-line window or special contexts
        if vim.fn.getcmdwintype() ~= '' then return end

        -- Don't close if we're in a special buffer context
        local current_buf = vim.api.nvim_get_current_buf()
        local current_filetype = vim.api.nvim_get_option_value('filetype', {
          buf = current_buf,
        })
        local current_buftype = vim.api.nvim_get_option_value('buftype', {
          buf = current_buf,
        })

        if current_buftype ~= '' or current_filetype == 'TelescopePrompt' then return end

        -- Only close if buffer was never modified and it's safe to do so
        if never_modified_buffers[bufnr] == true then
          pcall(vim.api.nvim_buf_delete, bufnr, {
            force = false,
          })
        end
      end,
    })

    -- Add mappings for hbac
    vim.keymap.set('n', '<leader>fW', function() hbac.close_unpinned() end, {
      desc = 'Close all unpinned buffers',
    })

    vim.keymap.set('n', '<leader>fP', function() hbac.toggle_pin() end, {
      desc = 'Toggle pin buffer',
    })
  end,
}
