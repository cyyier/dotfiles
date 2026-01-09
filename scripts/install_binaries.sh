#!/usr/bin/env bash

# --- Stage 2: Installation (Personal Mode Only) ---
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