-- LazyDocker - Docker TUI integration
return {
  'mgierada/lazydocker.nvim',
  dependencies = { 'akinsho/toggleterm.nvim' },
  event = 'VeryLazy',
  config = function()
    require('lazydocker').setup({
      border = 'rounded', -- valid options are "single" | "double" | "shadow" | "curved"
    })
  end,
  keys = {
    {
      '<leader>xd',
      function() require('lazydocker').open() end,
      desc = 'Open LazyDocker floating window',
    },
  },
}
