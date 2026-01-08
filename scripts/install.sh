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
DOTFILES="$HOME/dotfiles"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"
mkdir -p "$BIN_DIR" "$CONFIG_DIR"

# --- 2. Environment Selection ---
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
echo -e "\n${BLUE}Step 1: Syncing Configurations (Symlinks)...${NC}"
mkdir -p "$CONFIG_DIR/navi"

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
        if [ -d "$dest" ] && [ ! -L "$dest" ]; then rm -rf "$dest"; else rm -f "$dest"; fi
        ln -sfn "$src" "$dest"
        echo -e "  ${GREEN}✓${NC} Linked $(basename "$src")"
    else
        echo -e "  ${YELLOW}×${NC} Skip: $src not found"
    fi
done

# --- 4. Stage 2: Installation (Personal Mode Only) ---
if [ "$IS_COMPANY" = false ]; then
    echo -e "\n${BLUE}Step 2: Installing Tools & Plugins (Personal Mode)...${NC}"

    # Critical: Update PATH for the current script execution immediately
    export PATH="$BIN_DIR:$PATH"

    # Install Zsh if missing (Required for your SWE setup)
    if ! command -v zsh >/dev/null 2>&1; then
        echo "  Installing Zsh..."
        sudo apt update && sudo apt install zsh -y
    fi

    # Install Starship
    if ! command -v starship >/dev/null 2>&1; then
        echo "  Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$BIN_DIR" -y
    fi

    # Install Neovim (AppImage - The easiest way to get the latest version in WSL2)
    if ! command -v nvim >/dev/null 2>&1; then
        echo "  Installing Neovim..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage
        mv nvim.appimage "$BIN_DIR/nvim"
    fi

    # Ensure ~/.local/bin is added to your shell profiles permanently
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo "  Adding ~/.local/bin to PATH in .zshrc and .bashrc..."
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
    fi

    # Oh My Zsh & Plugins
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

    # LazyVim Bootstrap
    if [ ! -f "$DOTFILES/nvim/lua/config/lazy.lua" ]; then
        git clone https://github.com/LazyVim/starter "$DOTFILES/nvim"
        rm -rf "$DOTFILES/nvim/.git"
    fi
fi

# --- 5. Final Environment Health Check ---
echo -e "\n${BLUE}==========================================${NC}"
echo -e "${BLUE}🔎  Environment Health Check Report${NC}"
echo -e "${BLUE}==========================================${NC}"

# Re-check PATH to ensure it reflects current script session
[[ ":$PATH:" == *":$BIN_DIR:"* ]] && PATH_STATUS="${GREEN}OK${NC}" || PATH_STATUS="${RED}Missing${NC}"

[[ "$SHELL" == *"zsh"* ]] && echo -e "  Zsh Shell      : ${GREEN}OK${NC}" || echo -e "  Zsh Shell      : ${YELLOW}Not Default${NC}"
command -v starship >/dev/null 2>&1 && echo -e "  Starship UI    : ${GREEN}Ready${NC}" || echo -e "  Starship UI    : ${RED}Missing${NC}"
command -v nvim >/dev/null 2>&1 && echo -e "  Neovim/LazyVim : ${GREEN}Ready${NC}" || echo -e "  Neovim/LazyVim : ${RED}Missing${NC}"
echo -e "  Binary PATH    : $PATH_STATUS"

echo -e "${BLUE}==========================================${NC}"

# Final instruction for the user
if [[ "$SHELL" != *"zsh"* ]] && [ "$IS_COMPANY" = false ]; then
    echo -e "\n${YELLOW}Next Step:${NC} Run ${BLUE}'chsh -s \$(which zsh)'${NC} and restart WezTerm to activate your new shell."
fi

echo -e "\n${GREEN}✨ Setup Complete! Happy Coding!${NC}\n"