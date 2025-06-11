# Function Keys Layout for Tmux & Neovim

This document describes the optimized function key layout for seamless development workflow between tmux and Neovim.

## 🎯 Design Philosophy

- **Alt+1-9**: Window navigation with auto-creation and naming in tmux
- **F5-F8**: Common tmux actions (Create/Split/Zoom)
- **F9-F12**: Advanced tmux features (Menus/Tools/Help)
- **F1-F4**: Buffer navigation in Neovim
- **F5-F8**: File operations in Neovim
- **F9-F12**: Development tools in Neovim
- **Shift+F1-F12**: Extended operations in Neovim

## 🖥️ TMUX Function Keys

### Smart Window Navigation (Alt+1-9)
| Key | Action | Description |
|-----|--------|-------------|
| `Alt+1` | Go to Window 1 | Selects window 1, or creates it with custom name prompt |
| `Alt+2` | Go to Window 2 | Selects window 2, or creates it with custom name prompt |
| `Alt+3` | Go to Window 3 | Selects window 3, or creates it with custom name prompt |
| `Alt+4` | Go to Window 4 | Selects window 4, or creates it with custom name prompt |
| `Alt+5` | Go to Window 5 | Selects window 5, or creates it with custom name prompt |
| `Alt+6` | Go to Window 6 | Selects window 6, or creates it with custom name prompt |
| `Alt+7` | Go to Window 7 | Selects window 7, or creates it with custom name prompt |
| `Alt+8` | Go to Window 8 | Selects window 8, or creates it with custom name prompt |
| `Alt+9` | Go to Window 9 | Selects window 9, or creates it with custom name prompt |

### Pane Operations (F5-F8)
| Key | Action | Description |
|-----|--------|-------------|
| `F5` | New Window | Creates a new window in current path |
| `F6` | Horizontal Split | Split pane horizontally |
| `F7` | Vertical Split | Split pane vertically |
| `F8` | Toggle Zoom | Zoom/unzoom current pane |

### Session Management (F9-F12)
| Key | Action | Description |
|-----|--------|-------------|
| `F9` | Session Menu | Interactive session chooser |
| `F10` | Copy Mode | Enter copy/scroll mode |
| `F11` | List Sessions | Show all tmux sessions |
| `F12` | Rename Window | Rename current window |

## 📝 NEOVIM Function Keys

### Buffer Navigation (F1-F4)
| Key | Action | Description |
|-----|--------|-------------|
| `F1` | First Buffer | Jump to first buffer |
| `F2` | Previous Buffer | Navigate to previous buffer |
| `F3` | Next Buffer | Navigate to next buffer |
| `F4` | Last Buffer | Jump to last buffer |

### File Operations (F5-F8)
| Key | Action | Description |
|-----|--------|-------------|
| `F5` | Save File | Write current buffer to disk |
| `F6` | File Explorer | Open mini.files at current file location |
| `F7` | Find Files | Telescope file finder |
| `F8` | Live Grep | Search across all files |

### Development Tools (F9-F12)
| Key | Action | Description |
|-----|--------|-------------|
| `F9` | Show Buffers | Telescope buffer list |
| `F10` | Toggle Diagnostics | Show/hide diagnostic panel |
| `F11` | Toggle Terminal | Built-in terminal toggle |
| `F12` | Context Help | Smart help for word under cursor |

## 🔧 NEOVIM Extended Keys (Shift+Function)

### Tab Management (Shift+F1-F4)
| Key | Action | Description |
|-----|--------|-------------|
| `Shift+F1` | New Tab | Create new tab |
| `Shift+F2` | Previous Tab | Navigate to previous tab |
| `Shift+F3` | Next Tab | Navigate to next tab |
| `Shift+F4` | Close Tab | Close current tab |

### Advanced File Operations (Shift+F5-F8)
| Key | Action | Description |
|-----|--------|-------------|
| `Shift+F5` | Save All | Save all modified buffers |
| `Shift+F6` | Source File | Execute current Lua/Vim file |
| `Shift+F7` | Git Files | Telescope git file finder |
| `Shift+F8` | Grep Word | Search for word under cursor |

### Advanced Tools (Shift+F9-F12)
| Key | Action | Description |
|-----|--------|-------------|
| `Shift+F9` | Quickfix List | Show quickfix entries |
| `Shift+F10` | Diagnostics Float | Show diagnostic in floating window |
| `Shift+F11` | Split Terminal | Open terminal in horizontal split |
| `Shift+F12` | LSP Hover | Show LSP documentation |

## 🚀 Usage Tips

### Workflow Examples

**Starting a new project:**
1. `Alt+1` - Go to or create "main" window, name it appropriately
2. `Alt+2` - Create "test" window for testing
3. `Alt+3` - Create "docs" window for documentation
4. Use `F7` (neovim) - Find files to open in each window

**Smart window organization:**
1. `Alt+1` - Create/go to "editor" window (prompt: "editor")
2. `Alt+2` - Create/go to "terminal" window (prompt: "terminal") 
3. `Alt+3` - Create/go to "logs" window (prompt: "logs")
4. Navigate quickly between them with Alt+1-3

**Code navigation:**
1. `Alt+1-9` - Switch between different project windows
2. `F2/F3` (neovim) - Navigate between open buffers
3. `F9` (neovim) - Quick buffer switcher

**Debugging workflow:**
1. `F10` (neovim) - Check diagnostics
2. `F8` (neovim) - Search for error patterns
3. `F11` (neovim) - Open terminal for testing
4. `Shift+F10` - Show detailed diagnostic info

### Memory Aids

- **Alt+1-9**: Smart window navigation (tmux)
- **F1-4**: Buffer navigation (neovim)
- **F5-8**: Actions (Create/Save/Find/Search)
- **F9-12**: Tools (Menus/Diagnostics/Terminal/Help)
- **Shift+F**: Advanced/Extended operations (neovim)

### Enhanced Alt+Number Features

When you press `Alt+N` (where N is 1-9):
- **If window N exists**: Switch to that window immediately
- **If window N doesn't exist**: Prompt you with "Name for window N:" and create the window with your custom name
- **Smart defaults**: New windows inherit current directory path

## 🔄 Reload Configuration

After making changes, reload the configurations:

**Tmux:**
```bash
tmux source-file ~/.config/tmux/tmux.conf
```
**Or use:** `Prefix + r` (already bound in your config)

**Neovim:**
```vim
:source ~/.config/nvim/lua/config/keymaps.lua
```
**Or restart Neovim**

## 🎮 Alternative Considerations

If you prefer different layouts, consider these alternatives:

- **F1-F12**: All for tmux windows (1-12)
- **Ctrl+F1-F12**: Neovim operations
- **Alt+F1-F12**: System/global operations

The current layout balances smart tmux window management with Neovim productivity features. 
