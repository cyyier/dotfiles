#!/usr/bin/env bash

# --- Environment Selection ---
export IS_COMPANY=true
echo -e "${YELLOW}Select your environment (Auto-select Company Mode in 5s):${NC}"
echo -e "1) Company Environment  (Restricted: Symlinks only, no auto-installs)"
echo -e "2) Personal/WSL2        (Full: Auto-install binaries and plugins)"
read -t 5 -p "Selection [1]: " USER_INPUT || USER_INPUT="1"

if [[ "$USER_INPUT" == "2" ]]; then
    export IS_COMPANY=false
    echo -e "${GREEN}▶ Switched to: PERSONAL/WSL2 Mode${NC}"
else
    export IS_COMPANY=true
    echo -e "${BLUE}▶ Switched to: COMPANY/RESTRICTED Mode${NC}"
fi

# --- Environment Naming ---
echo -e "${YELLOW}Enter a nickname for this environment (e.g., WSL2, Google, MBP):${NC}"
read -p "Environment Name: " ENV_NAME

# If input is empty, set a default
if [[ -z "$ENV_NAME" ]]; then
    ENV_NAME="Generic"
fi

# Save the name to a hidden file
echo "$ENV_NAME" > "$HOME/.env_name_tag"
echo -e "${GREEN}▶ Environment tagged as: $ENV_NAME${NC}"