# Enhanced Neovim Integration for Tmux
# This file provides additional configuration for optimal neovim integration
# Source this file from your main tmux.conf

# ═══════════════════════════════════════════════════════════════════════════════
# Focus Events & File Synchronization
# ═══════════════════════════════════════════════════════════════════════════════

# Enable focus events for neovim auto-reload functionality
set -g focus-events on

# Better terminal title handling for neovim
set -g set-titles on
set -g set-titles-string "#T - tmux"

# Faster escape sequences for better neovim responsiveness
set -s escape-time 0

# Enable true color support for better neovim themes
set -ga terminal-overrides ',*256col*:Tc'
set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'

# Better clipboard integration
set -g @copy_use_osc52_fallback on

# ═══════════════════════════════════════════════════════════════════════════════
# Session & Window Management
# ═══════════════════════════════════════════════════════════════════════════════

# Start window and pane numbering from 1 for easier navigation
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Increase scrollback buffer for development logs
set -g history-limit 50000

# ═══════════════════════════════════════════════════════════════════════════════
# Enhanced Vim-Tmux Navigation
# ═══════════════════════════════════════════════════════════════════════════════

# These bindings work with the vim-tmux-navigator plugin
# They allow seamless navigation between tmux panes and vim splits

# Smart pane switching with awareness of vim splits
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'

# Tab navigation for cycling through panes
bind-key -n 'Tab' if-shell "$is_vim" 'send-keys Tab' 'select-pane -t :.+'
bind-key -n 'BTab' if-shell "$is_vim" 'send-keys S-Tab' 'select-pane -t :.-'

# Fallback for when vim-tmux-navigator isn't available
tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

# Copy mode vim-style navigation
bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
bind-key -T copy-mode-vi 'C-\' select-pane -l

# ═══════════════════════════════════════════════════════════════════════════════
# Development-Focused Key Bindings
# ═══════════════════════════════════════════════════════════════════════════════

# Quick pane splitting with intuitive keys
bind-key | split-window -h -c "#{pane_current_path}"
bind-key - split-window -v -c "#{pane_current_path}"

# New window in current path
bind-key c new-window -c "#{pane_current_path}"

# Quick session management
bind-key S choose-session
bind-key R command-prompt -I "#S" "rename-session '%%'"

# Project session creation
bind-key P command-prompt -p "Project name:" "new-session -d -s '%%' -c '#{pane_current_path}'"

# ═══════════════════════════════════════════════════════════════════════════════
# Copy Mode Enhancements
# ═══════════════════════════════════════════════════════════════════════════════

# Use vim-style copy mode
setw -g mode-keys vi

# Better copy mode bindings
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'
bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

# Quick copy to system clipboard
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'wl-copy'

# ═══════════════════════════════════════════════════════════════════════════════
# Status Line Integration
# ═══════════════════════════════════════════════════════════════════════════════

# Display indicators for when neovim is running
set -g status-right-length 100
set -g status-right '#{?pane_marked,#[reverse] MARKED #[noreverse],}#{?#{!=:#{client_width},80}, W:#{client_width}x#{client_height},} %H:%M %d-%b-%y'

# Show pane title (useful for neovim file names)
set -g pane-border-status top
set -g pane-border-format "#{pane_index} #{pane_current_command}"

# ═══════════════════════════════════════════════════════════════════════════════
# Session management will be handled by unified modern approach
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# Mouse Configuration
# ═══════════════════════════════════════════════════════════════════════════════

# Enhanced mouse support
set -g mouse on

# Don't exit copy mode when mouse selection is released
unbind-key -T copy-mode-vi MouseDragEnd1Pane

# Double-click to select word and copy
bind-key -T copy-mode-vi DoubleClick1Pane select-pane \; send-keys -X select-word \; send-keys -X copy-pipe-and-cancel 'wl-copy'
bind-key -n DoubleClick1Pane select-pane \; copy-mode -M \; send-keys -X select-word \; send-keys -X copy-pipe-and-cancel 'wl-copy'

# Triple-click to select line and copy
bind-key -T copy-mode-vi TripleClick1Pane select-pane \; send-keys -X select-line \; send-keys -X copy-pipe-and-cancel 'wl-copy'
bind-key -n TripleClick1Pane select-pane \; copy-mode -M \; send-keys -X select-line \; send-keys -X copy-pipe-and-cancel 'wl-copy'

# ═══════════════════════════════════════════════════════════════════════════════
# Hooks for Neovim Integration
# ═══════════════════════════════════════════════════════════════════════════════

# Automatically set window title based on active pane
set-hook -g pane-focus-in 'run-shell "tmux rename-window \"$(basename #{pane_current_path})\""'

# Update window title when pane changes
set-hook -g window-pane-changed 'run-shell "if [ \"#{pane_current_command}\" = \"nvim\" ]; then tmux rename-window \"nvim\"; fi"'

# ═══════════════════════════════════════════════════════════════════════════════
# Debugging & Development Helpers
# ═══════════════════════════════════════════════════════════════════════════════

# Show tmux messages for longer
set -g display-time 4000

# More verbose logging (uncomment for debugging)
# set -g @logging-path "$HOME/.local/share/tmux"

# Key to display pane information (useful for debugging focus issues)
bind-key i display-panes -d 0

# ═══════════════════════════════════════════════════════════════════════════════
# Performance Optimizations
# ═══════════════════════════════════════════════════════════════════════════════

# Reduce status update frequency when not needed
set -g status-interval 5

# Limit the size of the capture buffer
set -g buffer-limit 20

# Aggressive resize for better multi-client support
setw -g aggressive-resize on 
