#!/usr/bin/env bash
# Exit on any error
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
echo -e "1) Company Environment  (Restricted: Symlinks & Plugin managers only)"
echo -e "2) Personal/WSL2         (Full: Auto-install binaries and heavy tools)"
read -t 5 -p "Selection [1]: " USER_INPUT || USER_INPUT="1"

if [[ "$USER_INPUT" == "2" ]]; then
    IS_COMPANY=false
    echo -e "${GREEN}▶ Switched to: PERSONAL/WSL2 Mode${NC}"
else
    IS_COMPANY=true
    echo -e "${BLUE}▶ Switched to: COMPANY/RESTRICTED Mode${NC}"
fi

# --- Environment Naming (For your soso❤tag prompt) ---
echo -e "${YELLOW}Enter a nickname for this environment (e.g., WSL2, Google, MBP):${NC}"
read -p "Environment Name: " ENV_NAME
[[ -z "$ENV_NAME" ]] && ENV_NAME="Generic"
echo "$ENV_NAME" > "$HOME/.env_name_tag"
echo -e "${GREEN}▶ Environment tagged as: $ENV_NAME${NC}"

# --- 3. Stage 1: Symbolic Linking (Always Run) ---
echo -e "\n${BLUE}Step 1: Syncing Configurations (Symlinks)...${NC}"
mkdir -p "$CONFIG_DIR/navi" "$CONFIG_DIR/wezterm"

declare -A LINKS=(
    ["$DOTFILES/zsh/zshrc"]="$HOME/.zshrc"
    ["$DOTFILES/starship/starship.toml"]="$CONFIG_DIR/starship.toml"
    ["$DOTFILES/nvim"]="$CONFIG_DIR/nvim"
    ["$DOTFILES/tmux/tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES/navi/config.yaml"]="$CONFIG_DIR/navi/config.yaml"
    ["$DOTFILES/wezterm/wezterm.lua"]="$HOME/.wezterm.lua"
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

# --- 4. Stage 1.5: Plugin Managers (Always Run) ---
# TPM is lightweight and essential for your Tmux macaron theme
echo -e "\n${BLUE}Step 1.5: Checking Plugin Managers...${NC}"
TPM_PATH="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_PATH" ]; then
    echo -e "  ${BLUE}▶${NC} Installing Tmux Plugin Manager (TPM)..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_PATH" || echo "Git clone failed"
else
    echo -e "  ${GREEN}✓${NC} TPM already installed."
fi

# --- 5. Stage 2: Heavy Installation (Personal Mode Only) ---
if [ "$IS_COMPANY" = false ]; then
    echo -e "\n${BLUE}Step 2: Installing Tools (Personal Mode)...${NC}"
    export PATH="$BIN_DIR:$PATH"

    # Zsh
    ! command -v zsh >/dev/null 2>&1 && sudo apt update && sudo apt install zsh -y
    
    # Starship
    ! command -v starship >/dev/null 2>&1 && curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$BIN_DIR" -y

    # Neovim (AppImage)
    if ! command -v nvim >/dev/null 2>&1; then
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage && mv nvim.appimage "$BIN_DIR/nvim"
    fi

    # Oh My Zsh & Plugins
    [[ ! -d "$HOME/.oh-my-zsh" ]] && git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# --- 6. Final Health Check ---
echo -e "\n${BLUE}==========================================${NC}"
echo -e "${BLUE}🔎  Environment Health Check Report${NC}"
echo -e "${BLUE}==========================================${NC}"
command -v starship >/dev/null 2>&1 && echo -e "  Starship UI    : ${GREEN}Ready${NC}" || echo -e "  Starship UI    : ${RED}Missing${NC}"
command -v nvim >/dev/null 2>&1 && echo -e "  Neovim         : ${GREEN}Ready${NC}" || echo -e "  Neovim         : ${RED}Missing${NC}"
[ -d "$TPM_PATH" ] && echo -e "  Tmux Plugins   : ${GREEN}Ready${NC}" || echo -e "  Tmux Plugins   : ${RED}Missing${NC}"
echo -e "${BLUE}==========================================${NC}"

echo -e "\n${GREEN}✨ Setup Complete! Happy Coding!${NC}"
echo -e "${YELLOW}Tip: In Tmux, press 'prefix + I' to fetch plugins.${NC}\n"