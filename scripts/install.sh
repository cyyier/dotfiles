#!/usr/bin/env bash
set -e

# --- Color Definitions ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Initializing dotfiles environment for soso...${NC}"

# --- 1. Paths and Directories ---
# Define local paths for dotfiles repository, binaries, and configurations
DOTFILES="$HOME/dotfiles"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"
mkdir -p "$BIN_DIR" "$CONFIG_DIR"

# --- 2. Environment Selection (Company vs Personal) ---
# Default to Company Mode for security and compliance in restricted environments
IS_COMPANY=true
echo -e "${YELLOW}Select your environment (Auto-select Company Mode in 5s):${NC}"
echo -e "1) Company Environment  (Restricted: Symlinks only, no auto-installs)"
echo -e "2) Personal/WSL2        (Full: Auto-install binaries and plugins)"
read -t 5 -p "Selection [1]: " USER_INPUT || USER_INPUT="1"

if [[ "$USER_INPUT" == "2" ]]; then
    IS_COMPANY=false
    echo -e "${GREEN}▶ Switched to: PERSONAL/WSL2 Mode${NC}"
else
    IS_COMPANY=true
    echo -e "${BLUE}▶ Switched to: COMPANY/RESTRICTED Mode${NC}"
fi

# --- 3. Stage 1: Symbolic Linking (Always Run) ---
# Ensure configurations are synced regardless of the environment
echo -e "\n${BLUE}Step 1: Syncing Configurations (Symlinks)...${NC}"

mkdir -p "$CONFIG_DIR/navi"

# Map [source_path]=destination_path
declare -A LINKS=(
    ["$DOTFILES/zsh/zshrc"]="$HOME/.zshrc"
    ["$DOTFILES/starship/starship.toml"]="$CONFIG_DIR/starship.toml"
    ["$DOTFILES/nvim"]="$CONFIG_DIR/nvim"
    ["$DOTFILES/tmux/tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES/navi/config.yaml"]="$CONFIG_DIR/navi/config.yaml"
)

for src in "${!LINKS[@]}"; do
    dest="${LINKS[$src]}"
    if [ -e "$src" ]; then
        # Handle existing files or directories to ensure clean symlinking
        if [ -d "$dest" ] && [ ! -L "$dest" ]; then
            rm -rf "$dest"
        else
            rm -f "$dest"
        fi
        ln -sfn "$src" "$dest"
        echo -e "  ${GREEN}✓${NC} Linked $(basename "$src")"
    else
        echo -e "  ${YELLOW}×${NC} Skip: $src not found"
    fi
done

# --- 4. Stage 2: Installation (Personal Mode Only) ---
# External downloads are restricted to non-company environments
if [ "$IS_COMPANY" = false ]; then
    echo -e "\n${BLUE}Step 2: Installing Tools & Plugins (Personal Mode)...${NC}"

    # Install Starship cross-shell prompt
    if ! command -v starship >/dev/null 2>&1; then
        echo "  Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$BIN_DIR" -y
    fi

    # Install Oh My Zsh framework
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "  Cloning Oh My Zsh..."
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi

    # Clone Zsh performance and productivity plugins
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && \
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && \
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

    # Bootstrap LazyVim config if the directory is fresh
    if [ ! -f "$DOTFILES/nvim/lua/config/lazy.lua" ]; then
        echo "  Initializing LazyVim Starter..."
        git clone https://github.com/LazyVim/starter "$DOTFILES/nvim"
        rm -rf "$DOTFILES/nvim/.git"
    fi
else
    echo -e "\n${YELLOW}Step 2: Skipped (Company Mode).${NC}"
    echo "Please use internal package managers to install binaries."
fi

# --- 5. Final Environment Health Check ---
# Provide a visual report of the current setup status
echo -e "\n${BLUE}==========================================${NC}"
echo -e "${BLUE}🔎  Environment Health Check Report${NC}"
echo -e "${BLUE}==========================================${NC}"

[[ "$SHELL" == *"zsh"* ]] && echo -e "  Zsh Shell      : ${GREEN}OK${NC}" || echo -e "  Zsh Shell      : ${YELLOW}Not Default${NC}"
command -v starship >/dev/null 2>&1 && echo -e "  Starship UI    : ${GREEN}Ready${NC}" || echo -e "  Starship UI    : ${RED}Missing${NC}"
command -v nvim >/dev/null 2>&1 && echo -e "  Neovim/LazyVim : ${GREEN}Ready${NC}" || echo -e "  Neovim/LazyVim : ${RED}Missing${NC}"
[[ ":$PATH:" == *":$BIN_DIR:"* ]] && echo -e "  Binary PATH    : ${GREEN}OK${NC}" || echo -e "  Binary PATH    : ${RED}Missing ~/.local/bin${NC}"

echo -e "${BLUE}==========================================${NC}"

# --- 6. Tips for Restricted Environment ---
if [ "$IS_COMPANY" = true ]; then
    echo -e "\n${YELLOW}💡 Tips for Company Environment:${NC}"
    echo -e "  - Configs are synced via symlinks."
    echo -e "  - If tools are ${RED}Missing${NC}, refer to the internal Wiki for approved installation methods."
    echo -e "  - Avoid using ${RED}sudo${NC}; prioritize local user-space configurations."
fi

echo -e "\n${GREEN}✨ Setup Complete! Happy Coding!${NC}\n"