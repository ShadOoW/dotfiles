# Custom Tmux Theme
# Based on Tokyo Night colors but simplified for our needs

# Tokyo Night Color Palette
set -g @theme_bg "#1a1b26"          # Deep night background
set -g @theme_fg "#c0caf5"          # Soft blue-white text  
set -g @theme_accent "#7aa2f7"      # Bright blue accent
set -g @theme_inactive "#565f89"    # Muted inactive text
set -g @theme_active "#bb9af7"      # Purple highlight
set -g @theme_border "#3b4261"      # Subtle border
set -g @theme_green "#9ece6a"       # Success green
set -g @theme_orange "#ff9e64"      # Warning orange
set -g @theme_red "#f7768e"         # Error red
set -g @theme_cyan "#7dcfff"        # Info cyan

# Basic tmux styling
set -g status-style "bg=#{@theme_bg},fg=#{@theme_fg}"
set -g status-left-style "bg=#{@theme_bg},fg=#{@theme_fg}"
set -g status-right-style "bg=#{@theme_bg},fg=#{@theme_fg}"

# Pane border styling
set -g pane-border-style "fg=#{@theme_border}"
set -g pane-active-border-style "fg=#{@theme_accent}"

# Beautiful Tokyo Night prompt styling
set -g message-style "bg=#{@theme_accent},fg=#{@theme_bg},bold"
set -g message-command-style "bg=#{@theme_green},fg=#{@theme_bg},bold"
set -g mode-style "bg=#{@theme_active},fg=#{@theme_bg}"

# Tokyo Night Window Status - elegant and modern design
set -g window-status-style "bg=#{@theme_bg},fg=#{@theme_inactive}"
set -g window-status-current-style "bg=#{@theme_accent},fg=#{@theme_bg},bold"

# Fixed-width window display to prevent UI jumping when icons are added/removed
# Using 15 characters minimum width per window to accommodate icons and text
set -g window-status-format "#[fg=#{@theme_inactive}] #I #[fg=#{@theme_fg}]#{=12:window_name}#[fg=#{@theme_orange}]#F "
set -g window-status-current-format "#[fg=#{@theme_bg},bg=#{@theme_accent}] #I #[fg=#{@theme_bg},bold]#{=12:window_name}#[fg=#{@theme_bg}]#F #[fg=#{@theme_accent},bg=#{@theme_bg}]"

# Tokyo Night Status Bar - centered windows with proper spacing and gap from top

# Position status bar with gap from bottom (simulates gap from top in appearance)
set -g status-position bottom
set -g status-justify centre    # Center the window list
set -g window-status-separator ""
set -g status-interval 1

# Add visual gap and padding for better readability with centered layout
set -g status-style "bg=#{@theme_bg},fg=#{@theme_fg}"
set -g pane-border-status off
set -g pane-border-lines single

# Balanced padding for centered appearance - empty left/right sections for balance
set -g status-left ""
set -g status-right ""
set -g status-left-length 0
set -g status-right-length 0

# Add top gap by using pane border at top
set -g pane-border-status top
set -g pane-border-format ""
set -g pane-border-style "fg=#{@theme_bg}"

# Window activity styling
set -g window-status-activity-style "bg=#{@theme_bg},fg=#{@theme_active}"
set -g window-status-bell-style "bg=#{@theme_bg},fg=#{@theme_active}"

# Copy mode styling
set -g mode-style "bg=#{@theme_accent},fg=#{@theme_bg}"

# Clock mode styling
set -g clock-mode-colour "#7aa2f7"
set -g clock-mode-style 24 
