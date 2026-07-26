#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "Backing up existing configs to $BACKUP_DIR before restoring..."
mkdir -p "$BACKUP_DIR"

for item in "$DOTFILES_DIR"/.config/*/; do
  name=$(basename "$item")
  if [ -d "$HOME/.config/$name" ]; then
    mv "$HOME/.config/$name" "$BACKUP_DIR/$name"
    echo "Backed up existing ~/.config/$name"
  fi
  cp -r "$item" "$HOME/.config/"
  echo "Restored $name"
done

for f in .bashrc .bash_profile .bash_logout .XCompose; do
  if [ -f "$HOME/$f" ]; then
    cp "$HOME/$f" "$BACKUP_DIR/$f.orig"
  fi
  cp "$DOTFILES_DIR/$f" "$HOME/"
done

echo ""
echo "Done. Fresh Omarchy defaults were backed up to: $BACKUP_DIR"
echo "If anything looks wrong, you can restore from there."
