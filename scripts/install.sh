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

# --- Environment Naming ---
echo -e "${YELLOW}Enter a nickname for this environment:${NC}"
read -p "Environment Name: " ENV_NAME
[[ -z "$ENV_NAME" ]] && ENV_NAME="Generic"
echo "$ENV_NAME" > "$HOME/.env_name_tag"
echo -e "${GREEN}▶ Environment tagged as: $ENV_NAME${NC}"

# --- 3. Stage 1: Symbolic Linking (Always Run) ---
echo -e "\n${BLUE}Step 1: Syncing Configurations (Symlinks)...${NC}"
mkdir -p "$CONFIG_DIR/navi" "$CONFIG_DIR/wezterm" "$CONFIG_DIR/tealdeer"

declare -A LINKS=(
    ["$DOTFILES/zsh/zshrc"]="$HOME/.zshrc"
    ["$DOTFILES/starship/starship.toml"]="$CONFIG_DIR/starship.toml"
    ["$DOTFILES/nvim"]="$CONFIG_DIR/nvim"
    ["$DOTFILES/tmux/tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES/wezterm/wezterm.lua"]="$HOME/.wezterm.lua"
    ["$DOTFILES/tealdeer/config.toml"]="$CONFIG_DIR/tealdeer/config.toml"
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

# --- 4. Stage 1.5: Lightweight Managers (Always Run) ---
echo -e "\n${BLUE}Step 1.5: Checking Plugin Managers...${NC}"
TPM_PATH="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_PATH" ]; then
    echo -e "  ${BLUE}▶${NC} Installing TPM..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_PATH" || echo "Clone failed"
fi

# --- 5. Stage 1.6: tldr Check (Company Friendly) ---
# We link the config above, so even system-installed tldr will look pretty
if ! command -v tldr >/dev/null 2>&1; then
    if [ "$IS_COMPANY" = false ]; then
        echo -e "  ${BLUE}▶${NC} Installing tealdeer (tldr) for Personal mode..."
        curl -LO https://github.com/tealdeer-rs/tealdeer/releases/download/v1.8.1/tealdeer-linux-x86_64-musl
        chmod +x tealdeer-linux-x86_64-musl
        mv tealdeer-linux-x86_64-musl "$BIN_DIR/tldr"
        "$BIN_DIR/tldr" --update || true
    else
        echo -e "  ${YELLOW}!${NC} tldr not found. In Company mode, please use 'sudo apt install tldr' if allowed."
    fi
else
    echo -e "  ${GREEN}✓${NC} tldr already available."
fi

# --- 6. Stage 2: Heavy Installation (Personal Mode Only) ---
if [ "$IS_COMPANY" = false ]; then
    echo -e "\n${BLUE}Step 2: Installing Heavy Tools (Personal Mode)...${NC}"
    export PATH="$BIN_DIR:$PATH"
    
    # Starship
    ! command -v starship >/dev/null 2>&1 && curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$BIN_DIR" -y

    # Neovim (AppImage)
    if ! command -v nvim >/dev/null 2>&1; then
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage && mv nvim.appimage "$BIN_DIR/nvim"
    fi

    # Oh My Zsh Plugins
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

echo -e "\n${GREEN}✨ Setup Complete! Happy Coding!${NC}\n"