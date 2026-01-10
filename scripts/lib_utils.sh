#!/usr/bin/env bash

# --- Color Definitions ---
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export NC='\033[0m'

# --- Paths and Directories ---
# Defaults to $HOME/dotfiles if not already set
export DOTFILES="${DOTFILES:-$HOME/dotfiles}"
export BIN_DIR="$HOME/.local/bin"
export CONFIG_DIR="$HOME/.config"

# Ensure basic directories exist
mkdir -p "$BIN_DIR" "$CONFIG_DIR"

# --- Helper Functions ---
function section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

function success() {
    echo -e "  ${GREEN}✓ $1${NC}"
}

function info() {
    echo -e "  ${BLUE}ℹ $1${NC}"
}

function warn() {
    echo -e "  ${YELLOW}⚠ $1${NC}"
}