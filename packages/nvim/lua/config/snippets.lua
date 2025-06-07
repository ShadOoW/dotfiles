-- Snippet configuration
local M = {}

function M.setup()
    -- Check if luasnip is available
    local ok, luasnip = pcall(require, 'luasnip')
    if not ok then
        return
    end

    -- Set LuaSnip configuration
    luasnip.config.set_config({
        history = true,
        updateevents = 'TextChanged,TextChangedI',
        enable_autosnippets = true,
        ext_opts = {
            [require('luasnip.util.types').choiceNode] = {
                active = {
                    virt_text = {{'●', 'Orange'}}
                }
            }
        }
    })

    -- Load VS Code style snippets from friendly-snippets
    require('luasnip.loaders.from_vscode').lazy_load()

    -- Load Java snippets specifically
    require('luasnip.loaders.from_vscode').lazy_load({
        include = {'java'}
    })

    -- Custom Java snippets
    local s = luasnip.snippet
    local t = luasnip.text_node
    local i = luasnip.insert_node
    local c = luasnip.choice_node

    luasnip.add_snippets('java', {s('sout', {t('System.out.println('), i(1, 'text'), t(');')}),
                                  s('psvm', {t('public static void main(String[] args) {'), t({'', '    '}), i(1),
                                             t({'', '}'})}),
                                  s('fori',
        {t('for (int '), i(1, 'i'), t(' = 0; '), i(2, 'i'), t(' < '), i(3, 'length'), t('; '), i(4, 'i'), t('++) {'),
         t({'', '    '}), i(0), t({'', '}'})}), s('class',
        {c(1, {t('public '), t('private '), t('protected '), t('')}), t('class '), i(2, 'ClassName'), t(' {'),
         t({'', '    '}), i(0), t({'', '}'})})})

    -- Key mappings for snippet navigation
    vim.keymap.set({'i', 's'}, '<C-l>', function()
        if luasnip.choice_active() then
            luasnip.change_choice(1)
        end
    end, {
        desc = 'Change snippet choice'
    })

    vim.keymap.set({'i', 's'}, '<C-h>', function()
        if luasnip.choice_active() then
            luasnip.change_choice(-1)
        end
    end, {
        desc = 'Previous snippet choice'
    })
end

return M
