#!/bin/bash
# Apply Neovim personalisation.
# Copies custom plugins, snippets, keymaps and config on top of the
# LazyVim base. Does not touch lazy-lock.json (nvim regenerates it).
set -euo pipefail
REPO_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "  ${GREEN}✓${NC} $1"; }

SRC="$REPO_DIR/.config/nvim"
DEST="$HOME/.config/nvim"

mkdir -p "$DEST"

# Config entrypoints
cp "$SRC/init.lua"       "$DEST/init.lua"
cp "$SRC/lazyvim.json"   "$DEST/lazyvim.json"
cp "$SRC/stylua.toml"    "$DEST/stylua.toml"
[[ -f "$SRC/.neoconf.json" ]] && cp "$SRC/.neoconf.json" "$DEST/.neoconf.json"
ok "init.lua, lazyvim.json, stylua.toml"

# lua/config — keymaps, options, autocmds, lazy bootstrap
mkdir -p "$DEST/lua/config"
cp -r "$SRC/lua/config/." "$DEST/lua/config/"
ok "lua/config/ (keymaps, options, autocmds)"

# lua/custom — snippets (javascript, typescript, react, python, json, lua, markdown)
mkdir -p "$DEST/lua/custom"
cp -r "$SRC/lua/custom/." "$DEST/lua/custom/"
ok "lua/custom/ (custom snippets)"

# lua/plugins — custom plugin specs (themes, treesitter, render-markdown, etc.)
mkdir -p "$DEST/lua/plugins"
cp -r "$SRC/lua/plugins/." "$DEST/lua/plugins/"
ok "lua/plugins/ (custom plugin specs)"

# after/plugin — post-plugin autocmds
mkdir -p "$DEST/after/plugin"
cp -r "$SRC/after/plugin/." "$DEST/after/plugin/"
ok "after/plugin/"

# plugin/after — transparency and other late-loading configs
mkdir -p "$DEST/plugin/after"
cp -r "$SRC/plugin/after/." "$DEST/plugin/after/"
ok "plugin/after/"
