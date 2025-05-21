# Neovim Configuration

This is a modular Neovim configuration designed for a productive development environment.

## Structure

The configuration is organized in a modular way:

```
packages/nvim/
├── init.lua                  # Main entry point
├── lua/
│   ├── config/               # Core configuration
│   │   ├── autocmds.lua      # Auto commands
│   │   ├── keymaps.lua       # Key mappings
│   │   ├── lazy.lua          # Plugin manager setup
│   │   └── options.lua       # Vim options
│   ├── init.lua              # Secondary initialization
│   ├── lsp/                  # LSP configuration
│   │   ├── handlers.lua      # LSP event handlers
│   │   ├── servers/          # Server-specific configurations
│   │   └── setup.lua         # LSP main setup
│   ├── plugins/              # Plugin definitions
│   │   ├── cmp/              # Completion plugins
│   │   ├── debug/            # Debugging plugins
│   │   ├── editor/           # Editor enhancement plugins
│   │   ├── git/              # Git integration plugins
│   │   ├── init.lua          # Main plugins file
│   │   ├── lint.lua          # Linting plugins
│   │   ├── lsp/              # LSP plugins
│   │   ├── tools/            # Tool integration plugins
│   │   └── ui/               # UI enhancement plugins
│   └── utils/                # Utility modules
│       ├── file.lua          # File utilities
│       ├── keymap.lua        # Keymap utilities
│       └── string.lua        # String utilities
```

## Features

- **Modular Design**: Each aspect of the configuration is organized into separate modules
- **LSP Support**: Comprehensive language server protocol integration
- **Clean UI**: Modern and minimal interface with sensible defaults
- **Utility Modules**: Helper functions for common operations
- **Lazy Loading**: Fast startup with lazy-loaded plugins

## Key Mappings

Leader key is set to space. Some important key mappings:

- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Find buffers
- `<leader>e` - Toggle file explorer
- `<leader>f` - Format current buffer
- `gd` - Go to definition
- `K` - Show hover documentation
- `<C-h/j/k/l>` - Navigate between windows

See `lua/config/keymaps.lua` for a complete list of keymaps.

## Customization

To customize this configuration:

1. **Add new plugins**: Create or edit files in the `lua/plugins/` directory
2. **Modify options**: Edit `lua/config/options.lua`
3. **Change keymaps**: Edit `lua/config/keymaps.lua`
4. **Add auto commands**: Edit `lua/config/autocmds.lua`

## Requirements

- Neovim 0.8.0 or later
- Git (for plugin management)
- A Nerd Font (optional, for icons)
