#!/bin/bash
# Omarchy personalisation installer.
# Layers personal customisations on top of a clean Omarchy install.
# Never replaces Omarchy-managed files — uses Omarchy commands where required.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$REPO_DIR/scripts"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

header() { echo -e "\n${BOLD}--- $1 ---${NC}"; }
ok()     { echo -e "  ${GREEN}✓${NC} $1"; }
fail()   { echo -e "  ${RED}✗ FAILED:${NC} $1"; }

STEPS=(
  "01-prerequisites.sh"
  "02-theme.sh"
  "03-elephant-menus.sh"
  "04-hyprland.sh"
  "05-waybar.sh"
  "06-nvim.sh"
  "07-git.sh"
  "08-misc.sh"
  "09-verify.sh"
  "10-packages.sh"
)

echo -e "${BOLD}Omarchy Personalisation Installer${NC}"
echo "Repo: $REPO_DIR"

for step in "${STEPS[@]}"; do
  header "$step"
  if bash "$SCRIPTS_DIR/$step" "$REPO_DIR"; then
    ok "$step"
  else
    fail "$step"
    echo -e "\n${RED}Stopped at $step. Fix the error above and re-run install.sh.${NC}"
    exit 1
  fi
done

echo -e "\n${GREEN}${BOLD}All done. Your personalisation is applied on top of Omarchy.${NC}"
