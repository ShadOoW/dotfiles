-- Test script to verify LSP server configurations
local servers = {
  'superhtml',
  'cssls',
  'eslint',
  'tailwindcss',
  'astro',
  'jsonls',
  'yamlls',
  'marksman',
  'bashls',
  'dockerls',
  'denols',
  'clangd',
  'lua_ls',
}

print('Testing LSP server configurations...')

for _, server_name in ipairs(servers) do
  local ok, config = pcall(require, 'lsp.servers.' .. server_name)
  if ok then
    print('✓ ' .. server_name .. ' - configuration loaded successfully')
    if type(config) ~= 'table' then print('✗ ' .. server_name .. ' - configuration is not a table') end
  else
    print('✗ ' .. server_name .. ' - failed to load: ' .. tostring(config))
  end
end

print('Test completed.')
