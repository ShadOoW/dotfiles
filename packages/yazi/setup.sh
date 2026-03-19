#!/bin/bash
set -e

echo "Installing yazi plugins and flavor..."

# Theme
ya pkg add BennyOe/tokyo-night

# Official plugins
ya pkg add yazi-rs/plugins:smart-enter
ya pkg add yazi-rs/plugins:smart-filter
ya pkg add yazi-rs/plugins:jump-to-char
ya pkg add yazi-rs/plugins:full-border
ya pkg add yazi-rs/plugins:git
ya pkg add yazi-rs/plugins:chmod
ya pkg add yazi-rs/plugins:diff

# Community plugins
ya pkg add dedukun/relative-motions
ya pkg add dedukun/bookmarks
ya pkg add Joao-Queiroga/drag          # ripdrag drag-and-drop
ya pkg add ndtoan96/ouch               # archive compress/extract
ya pkg add boydaihungst/restore        # trash recovery
ya pkg add mgrachev/zoxide             # zoxide jump

echo "Done. Run 'yazi' to start."
