#!/usr/bin/env bash
# scripts/30-productivity.sh

# --- Ensure Utilities are loaded ---
# (Assuming utils.sh is sourced by the main install.sh, but for safety checks)
[[ -z "$GREEN" ]] && source "$(dirname "$0")/lib_utils.sh"

section "Installing Productivity Tools (The Holy Trinity)"

# --- 1. FZF (Fuzzy Finder) ---
# FZF is unique because it's best installed via git to get the install script
if command -v fzf >/dev/null 2>&1; then
    success "fzf is already installed."
else
    info "Installing fzf..."
    # Clone to ~/.fzf (Standard location)
    if [ ! -d "$HOME/.fzf" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        # Run the install script (enables key bindings and fuzzy completion)
        # --all: auto-answer yes to all
        "$HOME/.fzf/install" --all
        success "fzf installed successfully."
    else
        warn "~/.fzf directory already exists. Skipping clone."
    fi
fi

# --- 2. Zoxide (Smarter 'cd') ---
# Replaces autojump. It learns your directories.
if command -v zoxide >/dev/null 2>&1; then
    success "zoxide is already installed."
else
    if [ "$IS_COMPANY" = false ]; then
        info "Installing zoxide (Personal Mode)..."
        # Official install script, installs to ~/.local/bin
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        success "zoxide installed. (Make sure ~/.local/bin is in PATH)"
    else
        # In company mode, we avoid piping curl to bash blindly unless necessary
        warn "zoxide not found. In Company Mode, install manually if approved."
    fi
fi

# --- 3. Ripgrep (rg) ---
# The fastest search tool, respects .gitignore
if command -v rg >/dev/null 2>&1; then
    success "ripgrep (rg) is already installed."
else
    if [ "$IS_COMPANY" = false ]; then
        info "Installing ripgrep (Personal Mode)..."
        # Assuming Debian/Ubuntu/WSL for Personal Mode
        # If MacOS, use brew
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y ripgrep
        elif command -v brew >/dev/null 2>&1; then
            brew install ripgrep
        fi
    else
         warn "ripgrep (rg) not found. Please verify if 'rg' is allowed in corporate env."
    fi
fi

# --- 4. FD (Better 'find') ---
# Often used together with fzf
if command -v fd >/dev/null 2>&1; then
    success "fd is already installed."
else
    if [ "$IS_COMPANY" = false ]; then
        info "Installing fd-find..."
        if command -v apt >/dev/null 2>&1; then
            sudo apt install -y fd-find
            # Ubuntu installs it as 'fdfind', we usually alias it or link it
            [ -f /usr/bin/fdfind ] && [ ! -f ~/.local/bin/fd ] && ln -s /usr/bin/fdfind ~/.local/bin/fd
        fi
    else
        warn "fd not found."
    fi
fi
