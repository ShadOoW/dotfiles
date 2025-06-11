set -g prefix C-s
#▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
#   ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
#   ▄▄▄  Unbinds  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
#   ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
unbind -n F8
unbind -n F1
unbind -n F2
unbind -n F3
unbind -n F4
unbind -n F5
unbind -n F6
unbind -n F7
unbind -n F8
unbind -T copy-mode-vi [
unbind -T prefix /
unbind -T prefix c
unbind -T prefix .
unbind C-b
unbind C-a
unbind C-s
#   ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
#   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
bind C-s send-prefix
bind C-l send-keys 'C-l'
#   ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
#   ▄▄▄  Navigations  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
#   ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
bind -n M-h    previous-window
bind -n M-l    next-window

# Alt+Number bindings: Select existing window or create new named window
bind -n M-1 if-shell 'tmux list-windows | grep -q "^1:"' 'select-window -t 1; set-window-option -t 1 automatic-rename off; set-window-option -t 1 allow-rename off; set-window-option -t 1 set-titles off' 'new-window -t 1'
bind -n M-2 if-shell 'tmux list-windows | grep -q "^2:"' 'select-window -t 2; set-window-option -t 2 automatic-rename off; set-window-option -t 2 allow-rename off; set-window-option -t 2 set-titles off' 'new-window -t 2'  
bind -n M-3 if-shell 'tmux list-windows | grep -q "^3:"' 'select-window -t 3; set-window-option -t 3 automatic-rename off; set-window-option -t 3 allow-rename off; set-window-option -t 3 set-titles off' 'new-window -t 3'
bind -n M-4 if-shell 'tmux list-windows | grep -q "^4:"' 'select-window -t 4; set-window-option -t 4 automatic-rename off; set-window-option -t 4 allow-rename off; set-window-option -t 4 set-titles off' 'new-window -t 4'
bind -n M-5 if-shell 'tmux list-windows | grep -q "^5:"' 'select-window -t 5; set-window-option -t 5 automatic-rename off; set-window-option -t 5 allow-rename off; set-window-option -t 5 set-titles off' 'new-window -t 5'
bind -n M-6 if-shell 'tmux list-windows | grep -q "^6:"' 'select-window -t 6; set-window-option -t 6 automatic-rename off; set-window-option -t 6 allow-rename off; set-window-option -t 6 set-titles off' 'new-window -t 6'
bind -n M-7 if-shell 'tmux list-windows | grep -q "^7:"' 'select-window -t 7; set-window-option -t 7 automatic-rename off; set-window-option -t 7 allow-rename off; set-window-option -t 7 set-titles off' 'new-window -t 7'
bind -n M-8 if-shell 'tmux list-windows | grep -q "^8:"' 'select-window -t 8; set-window-option -t 8 automatic-rename off; set-window-option -t 8 allow-rename off; set-window-option -t 8 set-titles off' 'new-window -t 8'
bind -n M-9 if-shell 'tmux list-windows | grep -q "^9:"' 'select-window -t 9; set-window-option -t 9 automatic-rename off; set-window-option -t 9 allow-rename off; set-window-option -t 9 set-titles off' 'new-window -t 9'
bind -n M-0 if-shell 'tmux list-windows | grep -q "^0:"' 'select-window -t 0; set-window-option -t 0 automatic-rename off; set-window-option -t 0 allow-rename off; set-window-option -t 0 set-titles off' 'new-window -t 0'

# Extended function key bindings for tmux operations
# F5-F8: Additional tmux functionality
bind -n F5 new-window -c "#{pane_current_path}" -n "#{TMUX_WIN_ICO}#{e|+:#{session_windows},1}"  # Create new window
bind -n F6 split-window -h -c "#{pane_current_path}"                                            # Horizontal split
bind -n F7 split-window -v -c "#{pane_current_path}"                                            # Vertical split
bind -n F8 resize-pane -Z                                                                       # Toggle zoom

# F9-F12: Session and advanced operations
bind -n F9  choose-session                                                                      # Session menu
bind -n F10 copy-mode                                                                           # Enter copy mode
bind -n F11 list-sessions                                                                       # List sessions
bind -n F12 command-prompt -p "󱂬 Rename window: " -I "#W" "rename-window \"%%\" ; set-window-option automatic-rename off; set-window-option allow-rename off"  # Rename window

bind -n C-M-H  resize-pane     -L
bind -n C-M-L  resize-pane     -R
bind -n C-M-K  resize-pane     -U
bind -n C-M-J  resize-pane     -D
#  ╶╶╶╶╶╶───────╴──────╴──────╴─────╴────╴───╴──╴─╴─╶
bind -T prefix h   previous-window
bind -T prefix l   next-window
bind -T prefix k   switch-client   -p
bind -T prefix j   switch-client   -n
#  ╶╶╶╶╶╶───────╴──────╴──────╴─────╴────╴───╴──╴─╴─╶
bind -T prefix M-1 select-layout even-horizontal \; resize-pane -x 120
bind -T prefix M-2 select-layout even-horizontal \; resize-pane -x 80
bind -T prefix M-3 select-layout even-horizontal
bind -T prefix =   select-layout even-horizontal
bind -T prefix b   choose-buffer -Z

bind -T prefix p popup

bind -T prefix c   new-window -c "#{pane_current_path}" \; command-prompt -p "󱂬 New window name: " -I "󰆍#{e|+:#{session_windows},1}" "rename-window \"%%\" ; set-window-option automatic-rename off; set-window-option allow-rename off"
bind -T prefix C-c command-prompt -I "#{TMUX_SES_ICO}#{next_session_id}"          { new-session -c "#{pane_current_path}" -s "%%" -n "#{TMUX_WIN_ICO}" -A }
#  ╶╶╶╶╶╶───────╴──────╴──────╴─────╴────╴───╴──╴─╴─╶
bind -T prefix , command-prompt -p "󱂬 Rename window: " -I "#W" "rename-window \"%%\" ; set-window-option automatic-rename off; set-window-option allow-rename off"
bind -T prefix . command-prompt -I "#S" { rename-session "%%" }
#  ╶╶╶╶╶╶───────╴──────╴──────╴─────╴────╴───╴──╴─╴─╶

bind -T prefix v split-window  -h -c "#{pane_current_path}"  # prefix+v: Split vertically
bind -T prefix s split-window  -v -c "#{pane_current_path}"  # prefix+s: Split horizontally
#   ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
#   ▄▄▄  VI-Mode + Searches  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
#   ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
bind   -T prefix       /   copy-mode
bind   -T prefix       C-_ command-prompt -p "?google:"           "run -b  'chromium  --new-window \"https://google.com/search?q=%%&btnl\"'"
bind   -T copy-mode-vi y   send-keys      -X copy-pipe-and-cancel "xclip     -in -selection clipboard"
bind   -T copy-mode-vi v   send-keys      -X begin-selection
#   ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
#   ▄▄▄  Killings  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
#   ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
bind -T prefix d   detach-client
bind -T prefix C-D   confirm-before 'kill-session'
bind -T prefix C-k confirm-before 'kill-server'
#  ╶╶╶╶╶╶───────╴──────╴──────╴─────╴────╴───╴──╴─╴─╶
bind -n C-d  if-shell -b "[ $(tmux display-message \
  -p \"#{T:pane_current_command}\" | grep zsh | wc -l) -eq 1 \
  -a $(tmux list-windows | wc -l) -eq 1 \
  -a $(tmux list-panes | wc -l) -eq 1 ]" \
  { confirm-before 'detach' } { send 'C-d' }
#   ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
#   ▄▄▄  Menus  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
#   ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
bind -T prefix > display-menu -T \
  "#[align=centre]#{pane_index} (#{pane_id})" -x P -y P \
  "H Split" h { split-window -h } \
  "V Split" v { split-window -v } '' \
  "#{?#{>:#{window_panes},1},,-}Next Layout" n { nextl } '' \
  "#{?#{>:#{window_panes},1},,-}Swap Up"     u { swap-pane -U } \
  "#{?#{>:#{window_panes},1},,-}Swap Down"   d { swap-pane -D } \
         "#{?pane_marked_set,,-}Swap Marked" s { swap-pane } '' \
  "Kill" X { kill-pane } \
  "Respawn" R { respawn-pane -k } \
  "#{?pane_marked,Unmark,Mark}" m  { select-pane -m } \
  "#{?#{>:#{window_panes},1},,-}#{?window_zoomed_flag,Unzoom,Zoom}"  z { resize-pane -Z }
#  ╶╶╶╶╶╶───────╴──────╴──────╴─────╴────╴───╴──╴─╴─╶
bind -T prefix   C-r display-menu -T \
  '#[align=centre]#{window_index}:#{window_name} #[fg=#{@theme_fg}]' \
  '#[fg=#{@theme_accent}] ⏻ #[fg=#{@theme_fg}] Source' \
  r { source-file "$TMUX_CONFIG_DIR/tmux.conf" };
#  ╶╶╶╶╶╶───────╴──────╴──────╴─────╴────╴───╴──╴─╴─╶
bind -T prefix M command-prompt -T target { move-window -t "%%" }
#   ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
#   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
# vim:ft=tmux
