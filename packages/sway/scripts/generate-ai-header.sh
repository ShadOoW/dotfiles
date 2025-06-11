#!/bin/bash

# OpenAI API Image Generation Script for Arch Linux Themed Headers
# Usage: This script generates a prompt via GPT and then creates an image using DALL-E

set -euo pipefail

# Configuration
API_KEY_FILE="$HOME/.ssh/openai.key"
OUTPUT_DIR="$HOME/.local/share/openai"
OUTPUT_FILE="$OUTPUT_DIR/header"
API_BASE="https://api.openai.com/v1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check dependencies
check_dependencies() {
    local deps=("curl" "jq")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "$dep is required but not installed."
            exit 1
        fi
    done
}

# Load API key
load_api_key() {
    if [[ ! -f "$API_KEY_FILE" ]]; then
        log_error "API key file not found at $API_KEY_FILE"
        exit 1
    fi
    
    API_KEY=$(cat "$API_KEY_FILE" | tr -d '\n\r')
    if [[ -z "$API_KEY" ]]; then
        log_error "API key is empty"
        exit 1
    fi
}

# Create output directory
setup_output_dir() {
    mkdir -p "$OUTPUT_DIR"
}

# Generate prompt using GPT-3.5-turbo (free tier)
generate_prompt() {
    log_info "Generating creative prompt for Arch Linux themed image..."
    
    local system_prompt="You are an expert prompt engineer specializing in creating detailed, creative prompts for AI image generation."
    
    local user_prompt="Generate a concise but detailed prompt for creating a unique and cool Arch Linux themed header image that is 512x260 pixels. The image should be visually striking, modern, and represent the Arch Linux aesthetic. Include specific visual elements, colors, style preferences, and composition details. Keep it under 200 words but make it highly descriptive and creative."
    
    local json_payload=$(jq -n \
        --arg system "$system_prompt" \
        --arg user "$user_prompt" \
        '{
            "model": "gpt-3.5-turbo",
            "messages": [
                {"role": "system", "content": $system},
                {"role": "user", "content": $user}
            ],
            "max_tokens": 300,
            "temperature": 0.8
        }')
    
    local response=$(curl -s \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "$API_BASE/chat/completions")
    
    if ! echo "$response" | jq -e '.choices[0].message.content' > /dev/null 2>&1; then
        log_error "Failed to generate prompt. API response:"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        exit 1
    fi
    
    local generated_prompt=$(echo "$response" | jq -r '.choices[0].message.content')
    log_success "Generated prompt successfully"
    log_info "Prompt: $generated_prompt"
    echo "$generated_prompt"
}

# Generate image using DALL-E 3
generate_image() {
    local prompt="$1"
    log_info "Generating Arch Linux header image..."
    
    # DALL-E 3 doesn't support exact 512x260, so we'll use 1024x1024 and crop later
    local json_payload=$(jq -n \
        --arg prompt "$prompt Add: 512x260 aspect ratio, header banner format" \
        '{
            "model": "dall-e-3",
            "prompt": $prompt,
            "n": 1,
            "size": "1024x1024",
            "quality": "standard",
            "response_format": "url"
        }')
    
    local response=$(curl -s \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "$API_BASE/images/generations")
    
    if ! echo "$response" | jq -e '.data[0].url' > /dev/null 2>&1; then
        log_error "Failed to generate image. API response:"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
        exit 1
    fi
    
    local image_url=$(echo "$response" | jq -r '.data[0].url')
    log_success "Image generated successfully"
    echo "$image_url"
}

# Download and process image
download_image() {
    local image_url="$1"
    log_info "Downloading image..."
    
    # Download the image
    local temp_file=$(mktemp)
    if ! curl -s -o "$temp_file" "$image_url"; then
        log_error "Failed to download image"
        rm -f "$temp_file"
        exit 1
    fi
    
    # Determine file type
    local file_type=$(file --mime-type -b "$temp_file" | cut -d'/' -f2)
    local extension=""
    case "$file_type" in
        "jpeg") extension="jpg" ;;
        "png") extension="png" ;;
        "webp") extension="webp" ;;
        *) extension="jpg" ;;
    esac
    
    local final_output="$OUTPUT_FILE.$extension"
    
    # Check if ImageMagick is available for resizing
    if command -v convert > /dev/null 2>&1; then
        log_info "Resizing image to 512x260..."
        convert "$temp_file" -resize 512x260! "$final_output"
    else
        log_warning "ImageMagick not found. Saving original size image."
        cp "$temp_file" "$final_output"
    fi
    
    rm -f "$temp_file"
    log_success "Image saved to: $final_output"
    
    # Set wallpaper if swaybg is available
    if command -v swaymsg > /dev/null 2>&1; then
        log_info "Setting as wallpaper..."
        swaymsg "output * bg $final_output fill"
        log_success "Wallpaper updated!"
    fi
}

# Show notification
show_notification() {
    if command -v notify-send > /dev/null 2>&1; then
        notify-send "AI Header Generated" "New Arch Linux themed header image created!" --icon=applications-graphics
    fi
}

# Main execution
main() {
    log_info "Starting AI header generation..."
    
    check_dependencies
    load_api_key
    setup_output_dir
    
    # Step 1: Generate creative prompt
    local prompt=$(generate_prompt)

    echo "$prompt"
    
    # Step 2: Generate image using the prompt
    local image_url=$(generate_image "$prompt")

    echo "$image_url"
    
    # Step 3: Download and process the image
    download_image "$image_url"
    
    # Step 4: Show notification
    show_notification
    
    log_success "AI header generation completed successfully!"
}

# Run main function
main "$@" 
