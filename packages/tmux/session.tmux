# Modern TMUX Session Management
# Uses tmux-resurrect + tmux-continuum for robust session persistence

# ═══════════════════════════════════════════════════════════════════════════════
# Session Persistence Plugins
# ═══════════════════════════════════════════════════════════════════════════════

set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# ═══════════════════════════════════════════════════════════════════════════════
# Resurrect Configuration  
# ═══════════════════════════════════════════════════════════════════════════════

# Restore pane contents (terminal output)
set -g @resurrect-capture-pane-contents 'on'

# Restore these specific programs
set -g @resurrect-processes 'ssh less more man tail watch htop btop git zsh bash fish'

# Don't restore neovim - let neovim handle its own sessions
set -g @resurrect-strategy-nvim ''

# Use XDG directories for cleaner file organization
set -g @resurrect-dir '~/.local/share/tmux/resurrect'

# ═══════════════════════════════════════════════════════════════════════════════
# Continuum Configuration (Auto-save/restore)
# ═══════════════════════════════════════════════════════════════════════════════

# Auto-save every 10 minutes
set -g @continuum-save-interval '10'

# Auto-restore sessions on tmux server start (disabled initially to prevent hanging)
set -g @continuum-restore 'off'

# Show save status in status bar
set -g @continuum-boot 'on'

# ═══════════════════════════════════════════════════════════════════════════════
# Manual Session Management Keybindings
# ═══════════════════════════════════════════════════════════════════════════════

# Manual save/restore (in addition to automatic)
bind-key C-s run-shell '~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh'
bind-key C-r run-shell '~/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh'

# Session info and management
bind-key I display-message "Session: #S | Windows: #{session_windows} | Auto-save: #{?@continuum-save-interval,ON,OFF}" 
