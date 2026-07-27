# CLAUDE.md — Omarchy Dotfiles Guide

This file is the source of truth for any AI assistant (Claude or otherwise) working in this
repo. Read this before touching anything.

---

## What This Repo Does

Applies **personal customizations on top of a stock Omarchy install** without breaking any
Omarchy-managed system. Omarchy is an opinionated Arch Linux + Hyprland distro with its own
config management, theme switching, and update pipeline. This repo layers on top — it never
replaces anything Omarchy manages itself.

**Owner:** Shubham Basak  
**Machine:** Lenovo ThinkPad T480, Arch Linux / Omarchy / Hyprland  
**Repo:** `git@github.com:shubhambasak/omarchy-dotfiles.git`  
**Install:** `bash install.sh` from the repo root

---

## Critical Rules — Read Before Editing Anything

### 1. Never touch `~/.config/omarchy/current/`

This directory is **Omarchy's theme state**, managed exclusively by `omarchy theme set <name>`.
It is a tree of symlinks pointing at the active theme's files. If you copy files here manually,
theme switching breaks silently (waybar colors, wallpaper, terminal colors all go wrong).

**ONLY use:** `omarchy theme set Vantablack` (or whatever theme name).

### 2. Never edit `~/.local/share/omarchy/`

This is Omarchy's source tree, managed by git. Edits here:
- Are lost on the next `omarchy update`
- Cause git conflicts with upstream
- Break Omarchy's migration system

**Reading** `~/.local/share/omarchy/` is safe and encouraged (to understand commands).

### 3. Always restart services after config changes

| Component | Reload command |
|---|---|
| Hyprland | auto-reloads on save; then validate with `hyprctl reload && hyprctl configerrors` |
| Waybar | `omarchy restart waybar` — does NOT auto-reload |
| Hypridle | `pkill -x hypridle; setsid uwsm-app -- hypridle &>/dev/null &` |
| Walker | `omarchy restart walker` |

### 4. The elephant menus must exist

`~/.config/elephant/menus/` must contain 3 symlinks for the Styles > Background / Theme /
Unlock menus in the omarchy launcher to work. `omarchy reinstall configs` does NOT recreate
these. Script `03-elephant-menus.sh` handles this. If those menus are broken, run it.

### 5. After any waybar config change — restart waybar

Waybar reads config only on startup. Editing `config.jsonc` or `style.css` has no effect
until `omarchy restart waybar` is run.

---

## Repository Structure

```
omarchy-dotfiles-repo/
├── install.sh              — entry point; runs all scripts in order
├── CLAUDE.md               — this file
├── README.md               — user-facing quick reference
├── docs/
│   └── packages.md         — personal package list with sources
├── scripts/
│   ├── 01-prerequisites.sh — validates Omarchy + Hyprland are present
│   ├── 02-theme.sh         — copies custom backgrounds, sets Vantablack theme
│   ├── 03-elephant-menus.sh— creates ~/.config/elephant/menus/ symlinks
│   ├── 04-hyprland.sh      — copies hypr/ configs, restarts hypridle
│   ├── 05-waybar.sh        — copies waybar/ configs + cpu_temp_avg.sh
│   ├── 06-nvim.sh          — copies nvim/ config (not lazy-lock.json)
│   ├── 07-git.sh           — copies git identity (idempotent)
│   ├── 08-misc.sh          — copies starship, tmux, walker configs
│   ├── 09-verify.sh        — post-install health checks
│   └── 10-packages.sh      — installs personal apps (pacman + AUR)
└── .config/                — curated personal config files (mirrors ~/.config/)
    ├── git/config
    ├── hypr/               — autostart, input, looknfeel, hyprlock, hypridle
    ├── nvim/               — LazyVim base + custom plugins/snippets
    ├── omarchy/backgrounds/vantablack/  — 6 custom wallpapers
    ├── starship.toml
    ├── tmux/tmux.conf
    ├── walker/config.toml
    └── waybar/             — config.jsonc, style.css, scripts/cpu_temp_avg.sh
```

---

## What Each Script Does

### `01-prerequisites.sh`
Validates:
- Omarchy is installed (`omarchy` command exists)
- Hyprland is running (`hyprctl monitors`)
- Elephant modules exist in `~/.local/share/omarchy/default/elephant/`
- Warns (non-fatal) if `udiskie` is missing

### `02-theme.sh`
1. Copies `backgrounds/vantablack/` images → `~/.config/omarchy/backgrounds/vantablack/`
2. Runs `omarchy theme set Vantablack` (NEVER manually copies `omarchy/current/`)

### `03-elephant-menus.sh`
Creates `~/.config/elephant/menus/` and symlinks all 3 Omarchy lua modules:
- `omarchy_background_selector.lua`
- `omarchy_themes.lua`
- `omarchy_unlocks.lua`

These are symlinks INTO `~/.local/share/omarchy/default/elephant/` (read-only Omarchy files).
This is correct — we're pointing at the official modules, not copying them.

### `04-hyprland.sh`
Copies these files from repo `.config/hypr/` to `~/.config/hypr/`:
- `autostart.conf` — adds `udiskie` disk automount
- `input.conf` — sensitivity=0.35, natural scroll, 3-finger swipe gestures
- `looknfeel.conf` — window opacity 0.80/0.70, blur enabled (passes=9)
- `hyprlock.conf` — lock screen font: Adwaita Mono
- `hypridle.conf` — screensaver + auto-lock timers DISABLED

Then restarts hypridle.

Files NOT touched (leave Omarchy defaults): `hyprland.conf`, `monitors.conf`,
`bindings.conf`, `hyprsunset.conf`, `xdph.conf`, `envs.conf`.

### `05-waybar.sh`
Copies `config.jsonc`, `style.css`, `scripts/cpu_temp_avg.sh`. Makes script executable.
Runs `omarchy restart waybar`.

**Key waybar personalizations:**
- `modules-right` order: `… pulseaudio | cpu | cpu_temp_avg | battery`
- `custom/cpu_temp_avg` — reads coretemp hwmon, shows average of cores 2-5
- `battery.format-plugged` — `" {capacity}%"` (shows % when plugged in)
- `clock.format` — 12-hour (`{:%A %I:%M %p}`)
- `hyprland/workspaces.persistent-workspaces` — workspaces 1–9 always visible
- Font in `style.css` — Adwaita Mono

### `06-nvim.sh`
Copies nvim config: `lua/config/`, `lua/custom/`, `lua/plugins/`, `after/plugin/`,
`plugin/after/`, `init.lua`, `lazyvim.json`, `stylua.toml`.

**Does NOT copy `lazy-lock.json`** — that file is regenerated by nvim on startup and
tracking it causes constant noise.

### `07-git.sh`
Idempotent: if `user.name` is already set to a different identity, warns instead of
overwriting. Otherwise copies full `~/.config/git/config` with:
- `user.name = Shubham Basak`
- `user.email = bloggershubham7011@gmail.com`
- `core.autocrlf = false`

### `08-misc.sh`
Copies:
- `starship.toml` — shell prompt config
- `tmux/tmux.conf` — terminal multiplexer config
- `walker/config.toml` — app launcher config

### `09-verify.sh`
Post-install health checks (all must pass):
1. `hyprctl configerrors` — must be empty
2. `omarchy theme list` — must have >10 themes
3. `omarchy theme current` — must be `Vantablack`
4. Background symlink must exist and resolve
5. `waybar` process must be running
6. Elephant menus symlinks must exist
7. `cpu_temp_avg.sh` must be executable
8. 6+ custom Vantablack backgrounds must be present
9. `git user.name` must be set

### `10-packages.sh`
Installs personal apps with `pacman -S --needed --noconfirm` (skips already-installed).
AUR packages (`google-chrome`, `sioyek-git`) use `yay`. See `docs/packages.md` for the full
categorized list.

---

## Key Personal Settings

| Setting | Value | File |
|---|---|---|
| Theme | Vantablack | via `omarchy theme set Vantablack` |
| Active window opacity | 0.80 | `hypr/looknfeel.conf` |
| Inactive window opacity | 0.70 | `hypr/looknfeel.conf` |
| Blur | enabled, passes=9 | `hypr/looknfeel.conf` |
| Mouse sensitivity | 0.35 | `hypr/input.conf` |
| Natural scroll | enabled | `hypr/input.conf` |
| 3-finger swipe workspace | enabled | `hypr/input.conf` |
| Disk automount | udiskie | `hypr/autostart.conf` |
| Screensaver | DISABLED | `hypr/hypridle.conf` |
| Auto-lock/logout | DISABLED | `hypr/hypridle.conf` |
| Lock screen font | Adwaita Mono | `hypr/hyprlock.conf` |
| Waybar font | Adwaita Mono | `waybar/style.css` |
| Clock format | 12-hour | `waybar/config.jsonc` |
| Battery display | icon + % always | `waybar/config.jsonc` |
| CPU temp widget | after cpu icon | `waybar/config.jsonc` |
| Workspaces | 1–9 persistent | `waybar/config.jsonc` |
| Custom wallpapers | 6 images | `omarchy/backgrounds/vantablack/` |

---

## How to Add a New Personalization

1. Make the change live in `~/.config/…`
2. Test it works
3. Copy the changed file to its mirror location in `repo/.config/…`
4. If it requires a new install step, add it to the appropriate `scripts/XX-*.sh`
5. If it needs a new package, add to `scripts/10-packages.sh` AND `docs/packages.md`
6. Commit and push:
   ```bash
   cd ~/omarchy-dotfiles-repo
   git add -p          # review changes
   git commit -m "describe what changed"
   git push
   ```

---

## Debugging

```bash
# Hyprland errors (must be empty after any hypr/ change)
hyprctl configerrors

# Waybar isn't showing changes
omarchy restart waybar

# Background picker broken in launcher
ls -la ~/.config/elephant/menus/   # should show 3 symlinks

# Theme is broken / wrong colors
omarchy theme current               # check active theme
omarchy theme set Vantablack        # re-apply

# Hypridle not picking up changes
pkill -x hypridle 2>/dev/null; setsid uwsm-app -- hypridle &>/dev/null &

# Full omarchy debug
omarchy debug --no-sudo --print     # ALWAYS use these flags

# Re-run install from a specific step
bash scripts/05-waybar.sh ~/omarchy-dotfiles-repo

# Run all checks
bash scripts/09-verify.sh ~/omarchy-dotfiles-repo
```

---

## What NOT to Track in This Repo

| Path | Reason |
|---|---|
| `~/.config/omarchy/current/` | Omarchy theme state — managed by symlinks |
| `~/.config/omarchy/themes/` | Theme files — install via `omarchy theme install <url>` |
| `~/.config/nvim/lazy-lock.json` | Plugin lockfile — regenerated by nvim |
| Any browser profile directories | Personal data, large, volatile |
| Any `.bak.*` files | Backup files from `omarchy refresh` |
| `~/.local/share/omarchy/` | Omarchy source — never edit, never track |

---

## Fresh Install Sequence (worst-case recovery)

```bash
# 1. Fresh Omarchy install (follow omarchy.org instructions)
# 2. Verify Omarchy is healthy
omarchy debug --no-sudo --print

# 3. Clone this repo
git clone git@github.com:shubhambasak/omarchy-dotfiles.git ~/omarchy-dotfiles-repo

# 4. Install personal apps first (optional but useful for full setup)
bash ~/omarchy-dotfiles-repo/scripts/10-packages.sh

# 5. Apply all personalizations
bash ~/omarchy-dotfiles-repo/install.sh

# 6. Manual steps (cannot be automated)
#    - rustup default stable
#    - sudo systemctl enable --now docker && sudo usermod -aG docker $USER
#    - Sign in to 1Password, Vivaldi, Spotify
#    - Set background via: Omarchy Menu > Styles > Backgrounds
```
