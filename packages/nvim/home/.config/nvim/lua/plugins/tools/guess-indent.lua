-- Automatic indentation detection
-- Automatically detects and sets indentation style based on file content
return {
  'NMAC427/guess-indent.nvim',
  event = 'BufReadPre',
  opts = {},
}
