# Yazi Cheatsheet

## Navigate

| Key             | Action                              |
| --------------- | ----------------------------------- |
| `h / l`         | Parent dir / enter dir or open file |
| `j / k`         | Down / Up                           |
| `gg / G`        | Top / Bottom                        |
| `C-u / C-d`     | Half-page up / down                 |
| `<A-j> / <A-k>` | Scroll preview pane                 |
| `f<char>`       | Jump to char                        |
| `z`             | Zoxide jump (fzf)                   |
| `C-f`           | Smart filter (type to narrow)       |
| `.`             | Toggle hidden files                 |

## Relative motions (navigation only)

Press a number then `j` or `k`. The count shows at the bottom.
Example: `3j` = move down 3 rows. **Does not work with y/d/etc.**
Select multiple items with `Space`, then act on them.

## Go-to (`g…`)

`gh` home · `gd` Downloads · `gc` ~/.config · `gC` dotfiles · `gp` Pictures · `gt` tig

## Files

| Key      | Action                              |
| -------- | ----------------------------------- |
| `Space`  | Toggle select (purple marker)       |
| `Escape` | Deselect all / cancel               |
| `a`      | Create (end with `/` for directory) |
| `r`      | Rename                              |
| `y`      | Copy (teal marker on file)          |
| `x`      | Cut (orange marker on file)         |
| `p`      | Paste                               |
| `d`      | Trash                               |
| `D`      | Delete permanently                  |
| `C`      | Compress (ouch)                     |
| `<A-d>`  | Drag & drop (ripdrag)               |

> Markers: **purple** = selected with Space · **teal** = copied · **orange** = cut
> These are different from git status colors (green = new, red = deleted, etc.)

## Open / enter

| Key     | Behavior                                    |
| ------- | ------------------------------------------- |
| `l`     | Navigate into dir / open file (smart-enter) |
| `Enter` | Dir → new kitty terminal (yazi hides)       |
| `Enter` | Text/code → nvim in new kitty (yazi hides)  |
| `Enter` | Image/video/PDF → xdg-open                  |
| `!`     | New kitty terminal in current dir           |

> Press `mod+a` to bring yazi back after it hides itself.

## Copy path (`Y…`)

`Yp` full path · `Yn` filename · `Yd` directory path

## Tabs

`t` new · `[` / `]` prev/next

## Bookmarks (`b…`)

`bm` set · `b'` jump · `bd` delete

## Misc

`?` this cheatsheet · `~` built-in help
