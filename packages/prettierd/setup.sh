#!/bin/bash

echo "Setting up global prettier for neovim..."

# Change to the ~/.config/prettierd directory
cd ~/.config/prettierd || { echo "Failed to cd to ~/.config/prettierd"; exit 1; }

npm install

echo "prettier and its plugins are installed in ~/.config/prettierd"
