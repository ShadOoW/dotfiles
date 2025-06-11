#!/usr/bin/env bash

# Wiki Development Environment Launcher
# Starts qutebrowser and kitty terminal for wiki development
# Only starts components that aren't already running

set -euo pipefail

# Configuration
WIKI_DIR="/mnt/share/wiki"
WIKI_URL="http://localhost:2001"
WORKSPACE=4

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[WIKI-DEV]${NC} $1"
}

success() {
    echo -e "${GREEN}[WIKI-DEV]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WIKI-DEV]${NC} $1"
}

error() {
    echo -e "${RED}[WIKI-DEV]${NC} $1"
}

# Check if qutebrowser wiki instance is running
check_qutebrowser() {
    swaymsg -t get_tree | jq -r '.. | select(.app_id? == "org.qutebrowser.qutebrowser" and .instance? == "wiki-browser") | .id' | head -1
}

# Check if kitty wiki instance is running
check_kitty() {
    swaymsg -t get_tree | jq -r '.. | select(.app_id? == "kitty-wiki") | .id' | head -1
}

# Check if tmux wiki session exists
check_tmux_session() {
    tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -q "^wiki$"
}

# Start qutebrowser if not running
start_qutebrowser() {
    local browser_id
    browser_id=$(check_qutebrowser)
    
    if [[ -n "$browser_id" ]]; then
        warn "Qutebrowser wiki instance already running (window ID: $browser_id)"
        # Focus existing browser
        swaymsg "[con_id=$browser_id] focus"
        return 0
    fi
    
    log "Starting qutebrowser with wiki..."
    env QT_QPA_PLATFORM=xcb qutebrowser \
        --target window \
        --qt-arg name wiki-browser \
        "$WIKI_URL" &
    
    success "Qutebrowser started"
}

# Start kitty terminal with tmux session
start_terminal() {
    local kitty_id
    kitty_id=$(check_kitty)
    
    if [[ -n "$kitty_id" ]]; then
        warn "Kitty wiki terminal already running (window ID: $kitty_id)"
        # Focus existing terminal
        swaymsg "[con_id=$kitty_id] focus"
        return 0
    fi
    
    # Check if tmux session exists
    if check_tmux_session; then
        log "Tmux wiki session exists, starting terminal and attaching..."
        kitty --app-id=kitty-wiki -e zsh -c "tmux attach-session -t wiki" &
    else
        log "Creating new tmux wiki session and starting terminal..."
        if [[ ! -d "$WIKI_DIR" ]]; then
            error "Wiki directory does not exist: $WIKI_DIR"
            return 1
        fi
        kitty --app-id=kitty-wiki -e zsh -c "cd '$WIKI_DIR' && tmux new-session -A -s wiki" &
    fi
    
    success "Kitty terminal started"
}

# Check dependencies
check_dependencies() {
    local missing=()
    
    command -v qutebrowser >/dev/null || missing+=("qutebrowser")
    command -v kitty >/dev/null || missing+=("kitty")
    command -v tmux >/dev/null || missing+=("tmux")
    command -v jq >/dev/null || missing+=("jq")
    command -v swaymsg >/dev/null || missing+=("swaymsg")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}"
        return 1
    fi
}

# Main function
main() {
    log "Starting wiki development environment..."
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Start components
    start_qutebrowser
    start_terminal
}

# Run main function
main "$@" 
