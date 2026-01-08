#!/usr/bin/env bash
set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐭 Initializing dotfiles for soso...${NC}"

DOTFILES="$HOME/dotfiles"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# --- 1. Environment Check ---

HAS_ZSH=false
if command -v zsh >/dev/null 2>&1; then
    HAS_ZSH=true
    echo -e "${GREEN}✅ Zsh is available${NC}"
else
    echo -e "${YELLOW}⚠️  Zsh not found. Please install it via your package manager if possible.${NC}"
fi

# --- 2. Symbolic Links ---

echo -e "${BLUE}→ Creating symlinks...${NC}"

# Ensure config directories exist
mkdir -p "$HOME/.config/navi"

# Config mapping: source_path destination_path
declare -A LINKS=(
    ["$DOTFILES/tmux/tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES/bash/bashrc"]="$HOME/.bashrc"
    ["$DOTFILES/zsh/zshrc"]="$HOME/.zshrc"
    ["$DOTFILES/zsh/p10k.zsh"]="$HOME/.p10k.zsh"
    ["$DOTFILES/navi/config.yaml"]="$HOME/.config/navi/config.yaml"
    ["$DOTFILES/cheats/my_cheats"]="$HOME/.my_cheats"
)

for src in "${!LINKS[@]}"; do
    if [ -f "$src" ]; then
        ln -sf "$src" "${LINKS[$src]}"
        echo "  linked $(basename "$src")"
    fi
done

# --- 3. Zsh Environment Setup (Non-interactive) ---

if [ "$HAS_ZSH" = true ]; then
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    
    # Install Oh My Zsh if missing (Manual clone to avoid overwriting .zshrc)
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${BLUE}→ Cloning Oh My Zsh...${NC}"
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi

    # Install Plugins & Themes
    [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# --- 4. Modern Tools (Binary Installation to ~/.local/bin) ---

echo -e "${BLUE}→ Installing CLI tools...${NC}"

# fzf: The Fuzzy Finder
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --bin --no-update-rc
    ln -sf "$HOME/.fzf/bin/fzf" "$BIN_DIR/fzf"
fi

# navi: Interactive Cheat Sheet
if ! command -v navi >/dev/null 2>&1; then
    echo "  installing navi..."
    curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install | BIN_DIR="$BIN_DIR" bash
fi

# tealdeer: Fast tldr client
if ! command -v tldr >/dev/null 2>&1; then
    echo "  installing tldr (tealdeer)..."
    # Detect OS for binary download (Linux/macOS)
    OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
    curl -L "https://github.com/dbrgn/tealdeer/releases/latest/download/tealdeer-$OS_TYPE-x86_64-musl" -o "$BIN_DIR/tldr"
    chmod +x "$BIN_DIR/tldr"
    "$BIN_DIR/tldr" --update || true
fi

echo -e "${GREEN}✨ Done!${NC}"
echo -e "${YELLOW}Final Step:${NC} Ensure ${BLUE}$BIN_DIR${NC} is in your PATH."
echo "Add this to your .bashrc or .zshrc:"
echo "export PATH=\"\$HOME/.local/bin:\$PATH\""