#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

# --- Color Definitions for Feedback ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Initializing dotfiles environment for soso...${NC}"

# --- 1. Path Configurations ---
# Define core directories for dotfiles, binaries, and configurations
DOTFILES="$HOME/dotfiles"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"
DIST_DIR="$HOME/.local/share" # Directory for unpacked software distributions

# Ensure all required directories exist
mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$DIST_DIR"

# --- 2. Environment Selection Logic ---
# Default to Company mode for safety
IS_COMPANY=true
echo -e "${YELLOW}Select your environment (Auto-select Company Mode in 5s):${NC}"
read -t 5 -p "1) Company  2) Personal [Default 1]: " USER_INPUT || USER_INPUT="1"

if [[ "$USER_INPUT" == "2" ]]; then
    IS_COMPANY=false
    echo -e "${GREEN}▶ Switched to: PERSONAL/WSL2 Mode${NC}"
else
    IS_COMPANY=true
    echo -e "${BLUE}▶ Switched to: COMPANY/RESTRICTED Mode${NC}"
fi

# --- 3. Identity & Machine Naming ---
# Use system hostname as default, allow user override
CURRENT_HOSTNAME=$(hostname)
echo -e "\n${YELLOW}Identifying this machine...${NC}"
echo -e "Default name is: ${BLUE}$CURRENT_HOSTNAME${NC}"
read -t 10 -p "Enter a nickname for this environment (or press Enter to keep): " CUSTOM_NAME || CUSTOM_NAME=""

# Fallback to hostname if input is empty
FINAL_NAME="${CUSTOM_NAME:-$CURRENT_HOSTNAME}"
echo "$FINAL_NAME" > "$HOME/.env_name_tag"
echo -e "${GREEN}▶ Environment tagged as: $FINAL_NAME${NC}"

# --- 4. Smart Installation Helper Function ---
# Checks if command exists; if not and in Personal mode, downloads binary
# Arguments: 1:cmd_name, 2:download_url, 3:install_type(tar|direct)
smart_install() {
    local cmd=$1
    local url=$2
    local type=$3

    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $cmd already exists in PATH."
    elif [ "$IS_COMPANY" = false ]; then
        echo -e "  ${BLUE}▶${NC} Installing $cmd..."
        if [ "$type" == "tar" ]; then
            # Download and unpack tarballs
            curl -L -f -o "$HOME/temp.tar.gz" "$url"
            mkdir -p "$DIST_DIR/${cmd}-dist"
            tar xzf "$HOME/temp.tar.gz" -C "$DIST_DIR/${cmd}-dist" --strip-components=1
            ln -sf "$DIST_DIR/${cmd}-dist/bin/$cmd" "$BIN_DIR/$cmd"
            rm "$HOME/temp.tar.gz"
        else
            # Download standalone binaries directly
            curl -L -f -o "$BIN_DIR/$cmd" "$url"
            chmod +x "$BIN_DIR/$cmd"
        fi
        echo -e "  ${GREEN}✓${NC} $cmd installed successfully to $BIN_DIR"
    else
        echo -e "  ${YELLOW}!${NC} $cmd missing. Skipping binary install in Company Mode."
    fi
}

# --- 5. Symbolic Linking (Configuration Sync) ---
# Configurations are safe to link in both environments
echo -e "\n${BLUE}Step 1: Syncing Configurations (Symlinks)...${NC}"
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
        # Ensure parent directory exists for the destination
        mkdir -p "$(dirname "$dest")"
        # Force symbolic link creation (overwrite existing)
        ln -sfn "$src" "$dest"
        echo -e "  ${GREEN}✓${NC} Linked $(basename "$src")"
    else
        echo -e "  ${YELLOW}×${NC} Skip: $src not found"
    fi
done

# --- 6. Software Installation Stage ---
echo -e "\n${BLUE}Step 2: Smart Tool Installation Check...${NC}"

# Neovim: Latest stable v0.11.5
smart_install "nvim" "https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz" "tar"

# Tealdeer (tldr): Rust implementation of tldr
smart_install "tldr" "https://github.com/tealdeer-rs/tealdeer/releases/download/v1.8.1/tealdeer-linux-x86_64-musl" "direct"

# Starship: Cross-shell prompt
if ! command -v starship >/dev/null 2>&1 && [ "$IS_COMPANY" = false ]; then
    echo -e "  ${BLUE}▶${NC} Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$BIN_DIR" -y
fi

# --- 7. Plugin Management ---
echo -e "\n${BLUE}Step 3: Checking Plugin Managers & Add-ons...${NC}"

# TPM (Tmux Plugin Manager)
TPM_PATH="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_PATH" ]; then
    echo -e "  ${BLUE}▶${NC} Cloning TPM..."
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_PATH"
fi

# Oh My Zsh Plugins (Auto-suggestions & Syntax Highlighting)
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ -d "$HOME/.oh-my-zsh" ]; then
    # Clone productivity plugins if Oh My Zsh is present
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && \
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && \
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

echo -e "\n${GREEN}✨ Setup Complete for environment: $FINAL_NAME${NC}"
echo -e "${YELLOW}Note: Restart your shell or run 'source ~/.zshrc' to apply changes.${NC}\n"