#!/usr/bin/env bash
set -e

echo "🐭 Installing dotfiles for soso..."

DOTFILES="$HOME/dotfiles"

# --- 1. Environment Check ---

# Check if Zsh is installed
if command -v zsh >/dev/null 2>&1; then
    HAS_ZSH=true
    echo "✅ Zsh is available"
else
    # Attempt to install Zsh if on Debian/Ubuntu and running as root
    if command -v apt >/dev/null 2>&1 && [ "$EUID" -eq 0 ]; then
        echo "→ Attempting to install Zsh..."
        apt update && apt install -y zsh
        HAS_ZSH=true
    else
        HAS_ZSH=false
        echo "⚠️  Zsh not found and cannot be installed. Falling back to Bash."
    fi
fi

# --- 2. Create Symbolic Links ---

# tmux configuration
if [ -f "$DOTFILES/tmux/tmux.conf" ]; then
  echo "→ Linking tmux config"
  ln -sf "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

# Bash configuration (linked as a fallback shell)
if [ -d "$DOTFILES/bash" ]; then
  echo "→ Linking bash config"
  ln -sf "$DOTFILES/bash/bashrc" "$HOME/.bashrc"
fi

# Zsh setup
if [ "$HAS_ZSH" = true ]; then
    echo "🚀 Setting up Zsh environment..."
    
    # Link Zsh and Powerlevel10k configurations
    ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
    if [ -f "$DOTFILES/zsh/p10k.zsh" ]; then
        ln -sf "$DOTFILES/zsh/p10k.zsh" "$HOME/.p10k.zsh"
    fi

    # Install Oh My Zsh if not already present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "→ Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Install Powerlevel10k theme
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        echo "→ Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    fi

    # Install Zsh plugins (Autosuggestions & Syntax Highlighting)
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        echo "→ Downloading zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        echo "→ Downloading zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    # Attempt to change default shell to Zsh
    if [ "$SHELL" != "$(command -v zsh)" ]; then
        echo "→ Changing default shell to zsh..."
        chsh -s "$(command -v zsh)" || echo "⚠️  Warning: Failed to change default shell automatically."
    fi
fi

# Cheat sheets
if [ -f "$DOTFILES/cheats/my_cheats" ]; then
  echo "→ Linking cheat sheets"
  ln -sf "$DOTFILES/cheats/my_cheats" "$HOME/.my_cheats"
fi

echo "✨ Done! Please restart your terminal or type 'zsh' to enjoy."