-- .luarc.lua
-- If you want to keep the schema for reference, you can uncomment the next line:
-- $schema = "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json",
return {
    Lua = {
        runtime = {
            version = "LuaJIT"
        },
        workspace = {
            library = {"${workspaceFolder}/**"},
            checkThirdParty = false
        },
        diagnostics = {
            globals = {"vim"}
        },
        format = {
            enable = true,
            defaultConfig = {
                indent_style = "space",
                indent_size = "2",
                continuation_indent_size = "2"
            }
        }
    }
}
