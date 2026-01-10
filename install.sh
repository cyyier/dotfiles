#!/usr/bin/env bash
set -e

# --- Configuration ---
export DOTFILES="${HOME}/dotfiles"
SCRIPTS_DIR="${DOTFILES}/scripts"

# --- Load Modules ---
source "${SCRIPTS_DIR}/lib_utils.sh"

echo -e "${BLUE}🚀 Initializing dotfiles environment for soso...${NC}"

# --- Execution Steps ---
source "${SCRIPTS_DIR}/env_setup.sh"
source "${SCRIPTS_DIR}/link_configs.sh"
source "${SCRIPTS_DIR}/install_binaries.sh"
source "${SCRIPTS_DIR}/30-productivity.sh"

# --- Final Environment Health Check ---
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