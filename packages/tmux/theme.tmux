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

# Stunning window display with rounded corners effect and beautiful typography
set -g window-status-format "#[fg=#{@theme_inactive}]󰇘 #I #[fg=#{@theme_fg}]#W#[fg=#{@theme_orange}]#F #[fg=#{@theme_inactive}]"
set -g window-status-current-format "#[fg=#{@theme_bg},bg=#{@theme_accent}] #[fg=#{@theme_bg},bold]󰇘 #I #[fg=#{@theme_bg},bold]#W#[fg=#{@theme_bg}]#F #[fg=#{@theme_accent},bg=#{@theme_bg}]"

# Tokyo Night Status Bar - clean and focused on windows only
set -g status-left ""
set -g status-left-length 0
set -g status-right ""
set -g status-right-length 0

# Perfect spacing and alignment
set -g status-position bottom
set -g status-justify left
set -g window-status-separator ""
set -g status-interval 1

# Window activity styling
set -g window-status-activity-style "bg=#{@theme_bg},fg=#{@theme_active}"
set -g window-status-bell-style "bg=#{@theme_bg},fg=#{@theme_active}"

# Copy mode styling
set -g mode-style "bg=#{@theme_accent},fg=#{@theme_bg}"

# Clock mode styling
set -g clock-mode-colour "#{@theme_accent}"
set -g clock-mode-style 24 
