#!/bin/bash
# Install personal daily-work packages on top of a stock Omarchy system.
# Packages already installed are skipped silently (--needed).
# Requires: omarchy-keyring configured, yay available.
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $1"; }

# ---------------------------------------------------------------------------
# Pacman packages (official Arch + Omarchy repo)
# ---------------------------------------------------------------------------

PACMAN_PKGS=(
  # --- Browsers ---
  vivaldi                       # primary browser

  # --- Notes & Writing ---
  obsidian                      # markdown knowledge base
  typora                        # distraction-free markdown editor
  libreoffice-fresh             # office suite

  # --- Password Manager ---
  1password-beta                # GUI password vault
  1password-cli                 # CLI companion (op)

  # --- Media ---
  spotify                       # music streaming
  kdenlive                      # video editor
  obs-studio                    # screen recording / streaming

  # --- PDF & Documents ---
  zathura                       # minimal PDF/document reader
  zathura-pdf-mupdf             # PDF backend for zathura
  xournalpp                     # PDF annotation
  evince                        # GNOME document viewer
  imv                           # lightweight image viewer
  imagemagick                   # CLI image manipulation

  # --- IDEs ---
  visual-studio-code-bin        # VS Code
  cursor-bin                    # Cursor AI editor
  intellij-idea-community-edition  # Java / Kotlin IDE

  # --- File Sharing ---
  localsend                     # local network file sharing

  # --- Image Editing ---
  pinta                         # simple raster image editor

  # --- Containers ---
  docker
  docker-compose

  # --- Languages & Toolchains ---
  rustup                        # Rust toolchain manager (replaces rust pkg)
  jdk21-openjdk                 # Java 21
  clang                         # LLVM C/C++ compiler frontend
  llvm                          # LLVM toolchain
  luarocks                      # Lua package manager
  tree-sitter-cli               # parser generator CLI

  # --- Input Methods ---
  fcitx5                        # input method framework
  fcitx5-gtk                    # GTK integration
  fcitx5-qt                     # Qt integration

  # --- System Extras ---
  udiskie                       # disk automount daemon (used in autostart.conf)
  gnome-calculator
  gnome-disk-utility
  gnome-power-manager
  yaru-icon-theme               # Ubuntu/GNOME icon theme
  kvantum-qt5                   # Qt theming engine
  ttf-jetbrains-mono-nerd-basic # Nerd Font fallback for LazyVim/waybar icon glyphs

  # --- Printing ---
  cups
  cups-browsed
  cups-filters
  cups-pdf
  system-config-printer

  # --- CLI Utilities ---
  tldr                          # community-maintained man page summaries
  whois                         # domain lookup
  dust                          # du replacement
  eza                           # ls replacement
  bat                           # cat with syntax highlighting
  fzf                           # fuzzy finder
  fd                            # find replacement
  ripgrep                       # grep replacement
  jq                            # JSON processor
)

echo "  Installing pacman packages…"
if sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"; then
  ok "pacman packages installed (skipped already-present ones)"
else
  echo -e "  ${YELLOW}⚠ Some pacman packages failed — check output above.${NC}"
fi

# Non-interactive follow-ups for packages just installed above — these need
# no credentials or visual input, so there's no reason to leave them manual.
if command -v docker &>/dev/null; then
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  ok "docker enabled + $USER added to docker group (re-login to use docker without sudo)"
fi

if command -v rustup &>/dev/null; then
  rustup default stable
  ok "rustup default toolchain set to stable"
fi

# ---------------------------------------------------------------------------
# AUR packages (need yay)
# ---------------------------------------------------------------------------

AUR_PKGS=(
  google-chrome         # secondary / testing browser
  sioyek-git            # research-focused PDF reader
  bibata-cursor-theme   # cursor theme (Bibata Modern Ice)
)

if command -v yay &>/dev/null; then
  echo "  Installing AUR packages…"
  if yay -S --needed --noconfirm "${AUR_PKGS[@]}"; then
    ok "AUR packages installed"
  else
    warn "Some AUR packages failed — check output above"
  fi
else
  warn "yay not found — skipping AUR packages: ${AUR_PKGS[*]}"
  warn "Install yay first, then run: yay -S --needed ${AUR_PKGS[*]}"
fi

# ---------------------------------------------------------------------------
# Post-install notes
# ---------------------------------------------------------------------------
echo ""
ok "Packages done."
echo ""
echo "  Manual follow-ups (need credentials or visual input, cannot be scripted):"
echo "  • Sign in to 1Password, Vivaldi, Spotify"
echo "  • Re-login for the docker group membership to take effect"
echo "  • Configure fcitx5 for input method if needed"
