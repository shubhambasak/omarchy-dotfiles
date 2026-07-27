# Personal Package List

Packages installed on top of a stock Omarchy system via `scripts/10-packages.sh`.
Run with: `bash scripts/10-packages.sh` (or via `install.sh` which calls it automatically).

All packages use `--needed` — already-installed ones are silently skipped.

---

## Browsers

| Package | Source | Notes |
|---|---|---|
| `vivaldi` | Arch extra | Primary browser |
| `google-chrome` | AUR | Secondary / testing |
| `firefox` | Arch extra | Already installed by Omarchy |

---

## Notes & Writing

| Package | Source | Notes |
|---|---|---|
| `obsidian` | Arch extra | Markdown knowledge base |
| `typora` | Omarchy repo | Distraction-free markdown editor |
| `libreoffice-fresh` | Arch extra | Full office suite |

---

## Password Manager

| Package | Source | Notes |
|---|---|---|
| `1password-beta` | Omarchy repo | GUI vault |
| `1password-cli` | Omarchy repo | `op` CLI companion |

---

## Media

| Package | Source | Notes |
|---|---|---|
| `spotify` | Omarchy repo | Music streaming |
| `kdenlive` | Arch extra | Video editor |
| `obs-studio` | Arch extra | Screen recording / streaming |
| `mpv` | Arch extra | Already installed by Omarchy |

---

## PDF & Documents

| Package | Source | Notes |
|---|---|---|
| `zathura` | Arch extra | Minimal keyboard-driven viewer |
| `zathura-pdf-mupdf` | Arch extra | PDF backend for zathura |
| `xournalpp` | Arch extra | PDF annotation with stylus |
| `sioyek-git` | AUR | Research-focused PDF reader |
| `evince` | Arch extra | GNOME document viewer |
| `imv` | Arch extra | Lightweight image viewer |
| `imagemagick` | Arch extra | CLI image processing |

---

## IDEs & Editors

| Package | Source | Notes |
|---|---|---|
| `visual-studio-code-bin` | Omarchy repo | VS Code |
| `cursor-bin` | Omarchy repo | Cursor AI editor |
| `intellij-idea-community-edition` | Arch extra | Java / Kotlin IDE |

*(Neovim is managed by `omarchy-nvim` + `06-nvim.sh`)*

---

## Image Editing

| Package | Source | Notes |
|---|---|---|
| `pinta` | Arch extra | Simple raster image editor (Paint-like) |

---

## File Sharing

| Package | Source | Notes |
|---|---|---|
| `localsend` | Arch extra | LAN file sharing (AirDrop alternative) |

---

## Containers

| Package | Source | Notes |
|---|---|---|
| `docker` | Arch extra | Container runtime |
| `docker-compose` | Arch extra | Multi-container orchestration |

Post-install:
```bash
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # re-login after this
```

---

## Languages & Toolchains

| Package | Source | Notes |
|---|---|---|
| `rustup` | Arch extra | Rust toolchain manager |
| `jdk21-openjdk` | Arch extra | Java 21 |
| `clang` | Arch extra | LLVM C/C++ frontend |
| `llvm` | Arch extra | LLVM toolchain |
| `luarocks` | Arch extra | Lua package manager |
| `tree-sitter-cli` | Arch extra | Parser generator |

Post-install:
```bash
rustup default stable
```

---

## Input Methods

| Package | Source | Notes |
|---|---|---|
| `fcitx5` | Arch extra | Input method framework |
| `fcitx5-gtk` | Arch extra | GTK integration |
| `fcitx5-qt` | Arch extra | Qt integration |

---

## System Extras

| Package | Source | Notes |
|---|---|---|
| `udiskie` | Arch extra | USB/disk automount daemon (wired in `autostart.conf`) |
| `gnome-calculator` | Arch extra | Calculator |
| `gnome-disk-utility` | Arch extra | Disk partitioning GUI |
| `gnome-power-manager` | Arch extra | Power statistics |
| `yaru-icon-theme` | Arch extra | Ubuntu/GNOME icon theme |
| `kvantum-qt5` | Arch extra | Qt theming engine |

---

## Printing

| Package | Source | Notes |
|---|---|---|
| `cups` | Arch extra | Print spooler |
| `cups-browsed` | Arch extra | Network printer discovery |
| `cups-filters` | Arch extra | Print filters |
| `cups-pdf` | Arch extra | Print-to-PDF backend |
| `system-config-printer` | Arch extra | Printer management GUI |

---

## CLI Utilities

| Package | Source | Notes |
|---|---|---|
| `eza` | Arch extra | `ls` replacement |
| `bat` | Arch extra | `cat` with syntax highlighting |
| `fzf` | Arch extra | Fuzzy finder |
| `fd` | Arch extra | `find` replacement |
| `ripgrep` | Arch extra | `grep` replacement |
| `dust` | Arch extra | `du` replacement |
| `jq` | Arch extra | JSON processor |
| `tldr` | Arch extra | Simplified man pages |
| `whois` | Arch extra | Domain / IP lookup |

---

## Managed Elsewhere (not in this script)

| Package | Why excluded |
|---|---|
| `neovim` / `omarchy-nvim` | Managed by Omarchy + `06-nvim.sh` |
| `starship` | Omarchy default; config in `08-misc.sh` |
| `tmux` | Omarchy default; config in `08-misc.sh` |
| `lazygit` / `lazydocker` | Omarchy defaults |
| `btop` | Omarchy default |
| `hyprland` / `waybar` / `walker` | Omarchy core |
| `alacritty` | Omarchy default terminal |
| `git` / `gh` | Omarchy default; identity in `07-git.sh` |
| `mise` | Omarchy default runtime manager |
