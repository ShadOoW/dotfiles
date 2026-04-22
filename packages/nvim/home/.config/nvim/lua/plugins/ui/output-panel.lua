return {
  'mhanberg/output-panel.nvim',
  event = 'VeryLazy',
  config = function()
    -- Only max_buffer_size is accepted; height/filetype/border etc. are not valid options
    require('output_panel').setup({})
  end,
}
