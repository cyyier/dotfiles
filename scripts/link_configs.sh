#!/usr/bin/env bash

# --- Stage 1: Symbolic Linking ---
echo -e "\n${BLUE}Step 1: Syncing Configurations (Symlinks)...${NC}"
mkdir -p "$CONFIG_DIR/navi"
mkdir -p "$HOME/.local/share/navi/cheats"

declare -A LINKS=(
    ["$DOTFILES/zsh/zshrc"]="$HOME/.zshrc"
    ["$DOTFILES/starship/starship.toml"]="$CONFIG_DIR/starship.toml"
    ["$DOTFILES/nvim"]="$CONFIG_DIR/nvim"
    ["$DOTFILES/tmux/tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES/navi/config.yaml"]="$CONFIG_DIR/navi/config.yaml"
    ["$DOTFILES/cheats/my_cheats.cheat"]="$HOME/.local/share/navi/cheats/my_cheats.cheat"
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