#!/bin/bash

# ANSI colors
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

SEPARATOR="───────────────────────────────────"

echo -e "\n${CYAN}${SEPARATOR}${RESET}"
echo -e "🚀 ${YELLOW}Starting dotfiles installation...${RESET}"
echo -e "${CYAN}${SEPARATOR}${RESET}\n"

# Section 1: Install packages
echo -e "${GREEN}📦 Installing required packages...${RESET}"
bash scripts/install_packages.sh
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; then
    echo -e "❌ ${YELLOW}Error in install_packages.sh (Exit Code: $EXIT_CODE)${RESET}"
    exit $EXIT_CODE
fi
echo -e "✅ ${GREEN}Packages installed successfully!${RESET}\n"

# Section 2: Setup symlinks
echo -e "${CYAN}${SEPARATOR}${RESET}"
echo -e "🔗 ${YELLOW}Setting up symlinks...${RESET}"
echo -e "${CYAN}${SEPARATOR}${RESET}"
bash scripts/setup_symlinks.sh
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; then
    echo -e "❌ ${YELLOW}Error in setup_symlinks.sh (Exit Code: $EXIT_CODE)${RESET}"
    exit $EXIT_CODE
fi
echo -e "✅ ${GREEN}Symlinks configured successfully!${RESET}\n"

# Section 3: Post-install tasks
echo -e "${CYAN}${SEPARATOR}${RESET}"
echo -e "🔧 ${YELLOW}Running post-install setup...${RESET}"
echo -e "${CYAN}${SEPARATOR}${RESET}"
bash scripts/post_install.sh
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; then
    echo -e "❌ ${YELLOW}Error in post_install.sh (Exit Code: $EXIT_CODE)${RESET}"
    exit $EXIT_CODE
fi
echo -e "✅ ${GREEN}Post-install setup completed!${RESET}\n"

# Completion message
echo -e "${CYAN}${SEPARATOR}${RESET}"
echo -e "🎉 ${GREEN}Dotfiles setup completed successfully!${RESET}"
echo -e "${CYAN}${SEPARATOR}${RESET}"

