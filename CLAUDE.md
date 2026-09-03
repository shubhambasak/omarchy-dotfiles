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
**Machine:** Lenovo ThinkPad T480, Arch Linux / Omarchy **quattro** / Hyprland
**Repo:** `git@github.com:shubhambasak/omarchy-dotfiles.git`
**Install:** `bash install.sh` from the repo root

---

## Omarchy Quattro — Read This First

This repo targets **Omarchy quattro**, the package-backed rewrite of Omarchy (as opposed to
the older git-checkout-based Omarchy 3.x). If you're setting up on a pre-quattro install, run
`omarchy-upgrade-to-quattro` first — this repo's scripts assume the quattro layout and will
fail their prerequisite checks otherwise.

Quattro changed a lot more than "Omarchy 3.x with a new package manager":

| Area | Omarchy 3.x | Omarchy quattro |
|---|---|---|
| Omarchy's own source | git checkout at `~/.local/share/omarchy` | real package at `/usr/share/omarchy` |
| Hyprland config format | `.conf` (hyprlang) | `.lua` — same override file *locations*, new syntax |
| Bar | waybar | own Quickshell-based `omarchy-shell` (bar + notifications + idle/lock + launcher, all one process) |
| Idle/lock | hypridle + hyprlock | built into `omarchy-shell`, configured via `omarchy toggle idle`/`omarchy toggle screensaver` and `~/.config/omarchy/shell.json` |
| App launcher | walker | `omarchy-menu` (part of `omarchy-shell`) |
| Notifications | mako | built into `omarchy-shell` |
| Theme state | `~/.config/omarchy/current/` | `~/.local/state/omarchy/current/` |

**We deliberately went back to real waybar** (see "Why waybar instead of the new bar" below).
Everything else (idle/lock, launcher, notifications) stays on Omarchy's new built-in shell.

### Why waybar instead of the new bar

The new `omarchy-shell` bar's app-drawer is a narrow single-column list shared with the root
menu (not a dedicated grid like the old walker), and — more importantly — its own bar has a
confirmed upstream bug: clicking a bar-widget-panel icon twice sometimes opens a *different*
panel instead of closing the current one (two separate code paths track "is this panel open"
and can drift out of sync; see `omarchy-hide-all-panels` below for the workaround). Real
waybar doesn't have either issue, so the bar itself was restored while everything else
(idle/lock/notifications/launcher) stays on Omarchy's new shell.

`omarchy-shell`'s own bar is **hidden**, not removed — its process keeps running so idle/lock/
notifications/the app launcher keep working. Only the bar UI is hidden (`omarchy toggle
bar-off on`). Waybar's bluetooth/network/audio icons call each panel's own dedicated IPC
target directly (e.g. `omarchy-shell omarchy.bluetooth toggle`) rather than the generic
`omarchy-shell shell toggle <id>` path, specifically to avoid the toggle bug above.

### `SUPER+Q` — bar panel close-all

Bound to `~/.local/bin/omarchy-hide-all-panels`, installed by `04-hyprland.sh`. Force-closes
any open Omarchy bar panel (bluetooth/network/audio/agents/monitor/power/menu) regardless of
the toggle-state bug — the reliable way to close a stuck/wrong panel.

---

## Meta Rules — Commit Hygiene

**Do not leave any trace of AI assistance in git metadata.**

- Never add `Co-Authored-By`, `Signed-off-by`, or any trailer that names an AI model, assistant, or service (Claude, GPT, Copilot, etc.)
- Never mention AI tools in commit messages, PR descriptions, or any version-controlled text
- Commits must appear as sole work of the repo owner (`Shubham Basak`)
- If your tooling auto-appends these trailers, strip them before committing

---

## Critical Rules — Read Before Editing Anything

### 1. Never touch `~/.local/state/omarchy/current/`

This directory is **Omarchy's theme state** (moved here from `~/.config/omarchy/current/` in
quattro), managed exclusively by `omarchy theme set <name>`. It is a tree of symlinks pointing
at the active theme's files. If you copy files here manually, theme switching breaks silently
(bar colors, wallpaper, terminal colors all go wrong).

**ONLY use:** `omarchy theme set Vantablack` (or whatever theme name).

### 2. Never edit `/usr/share/omarchy/`

This is Omarchy's package-owned tree (quattro's replacement for the old
`~/.local/share/omarchy` git checkout). Edits here are lost on the next package update and can
break Omarchy's own plugin/shell resolution in ways that are hard to diagnose.

**Reading** `/usr/share/omarchy/` is safe and encouraged (to understand commands, plugin
source, default configs). If you need to customize a built-in `omarchy-shell` plugin, clone it
first: `omarchy plugin clone <plugin-id>` — this copies it to
`~/.config/omarchy/plugins/<yourname>.<name>/`, which is yours to edit. Note that plugins of
kind `menu` (the root/apps/settings menu system) only pick up a clone swap on a **full
`omarchy-shell` restart**, not the usual hot-reload — bar-widget-only plugins hot-reload fine.

### 3. Always restart services after config changes

| Component | Reload command |
|---|---|
| Hyprland | auto-reloads on save; then validate with `hyprctl reload && hyprctl configerrors` |
| Waybar | manual restart — `pkill -x waybar; setsid uwsm-app -- waybar &` (no `omarchy restart waybar` under quattro; that command no longer exists) |
| omarchy-shell | `omarchy-launch-shell` for a full restart (needed for `menu`-kind plugin changes); `omarchy-shell shell rescanPlugins` hot-reloads bar-widget plugins |

### 4. After any waybar config change — restart waybar

Waybar reads config only on startup. Editing `config.jsonc` or `style.css` has no effect
until waybar is restarted (see above — `omarchy restart waybar` doesn't exist under quattro).

---

## Repository Structure

```
omarchy-dotfiles-repo/
├── install.sh              — entry point; runs all scripts in order
├── CLAUDE.md                — this file
├── README.md                — user-facing quick reference
├── docs/
│   └── packages.md          — personal package list with sources
├── scripts/
│   ├── 01-prerequisites.sh  — validates Omarchy quattro is present
│   ├── 02-theme.sh          — installs the Limine theme-sync hook, copies custom backgrounds, sets Vantablack theme
│   ├── 03-desktop-overrides.sh — fixes the app-drawer second-window bug (Files/Power Stats/Disks)
│   ├── 04-hyprland.sh       — copies hypr/*.lua configs, installs SUPER+Q helper, sets font/idle/screensaver/shell.toml
│   ├── 05-waybar.sh         — installs waybar package, copies configs, hides Omarchy's own bar
│   ├── 06-nvim.sh           — copies nvim/ config (not lazy-lock.json)
│   ├── 07-git.sh            — copies git identity (idempotent)
│   ├── 08-misc.sh           — starship, tmux, terminal fonts, GTK/Nautilus settings
│   ├── 09-verify.sh         — post-install health checks
│   └── 10-packages.sh       — installs personal apps (pacman + AUR)
└── .config/                 — curated personal config files (mirrors ~/.config/)
    ├── alacritty/, kitty/, ghostty/, foot/ — terminal configs (Adwaita Mono, size 13;
    │                                        foot/kitty/ghostty also fall back to
    │                                        JetBrainsMono Nerd Font for icon glyphs)
    ├── git/config
    ├── gtk-4.0/gtk.css       — Nautilus sidebar spacing + icon-grid top margin
    ├── hypr/                 — *.lua overrides (monitors, input, bindings, looknfeel, autostart)
    ├── nvim/                 — LazyVim base + custom plugins/snippets
    ├── omarchy/
    │   ├── backgrounds/vantablack/ — 6 custom wallpapers
    │   ├── hooks/theme-set.d/limine-theme-sync.sh — recolors Limine on every theme change
    │   └── shell.toml        — omarchy-shell popup panel (bluetooth/network/agents) font size
    ├── starship.toml
    ├── tmux/tmux.conf
    └── waybar/               — config.jsonc, style.css, scripts/cpu_temp_avg.sh
```

`.local/bin/omarchy-hide-all-panels` (repo root) mirrors `~/.local/bin/` — installed by
`04-hyprland.sh`.

---

## What Each Script Does

### `01-prerequisites.sh`
Validates:
- Omarchy is installed (`omarchy` command exists)
- `/usr/share/omarchy` exists (package-backed quattro layout, not legacy git-checkout)
- Theme state file exists at the new quattro path
- Hyprland is running (`hyprctl version`)
- Warns (non-fatal) if `omarchy-shell` isn't running, or if `udiskie` is missing

### `02-theme.sh`
1. Copies `backgrounds/vantablack/` images → `~/.config/omarchy/backgrounds/vantablack/`
2. Installs the Limine theme-sync hook — **before** step 3, not after. Installing it after
   `omarchy theme set` would mean the very first theme-set never triggers it (the hook wouldn't
   exist yet at that point) — this bit us once, don't reorder it back.
3. Runs `omarchy theme set Vantablack` (NEVER manually copies theme state)

### `03-desktop-overrides.sh`
Fixes a real Omarchy quattro bug: `org.gnome.Nautilus.desktop`, `org.gnome.PowerStats.desktop`,
and `org.gnome.DiskUtility.desktop` all ship `DBusActivatable=true`. The app-drawer launches
everything via `gtk-launch <id>.desktop`, which for an already-running D-Bus-activatable app
sends an `Activate()` call instead of spawning a process — that just re-presents the existing
window, so opening a second Files/Power-Stats/Disks window from the drawer silently does
nothing. Generates user-level `.desktop` overrides in `~/.local/share/applications/` from the
*current* system files (not stored statically in this repo — survives upstream package
updates) with that one line stripped, then runs `update-desktop-database`.

### `04-hyprland.sh`
Copies these files from repo `.config/hypr/` to `~/.config/hypr/` (all `.lua`, quattro's
config format — same override locations as the old `.conf` files, new syntax):
- `hyprland.lua` — entrypoint; loads the personal overrides below plus 9 persistent-workspace rules
- `monitors.lua` — scale=1.1, GDK_SCALE=1. **Not a universal constant** — measured correct on
  this 1080p 14" panel; a flat scale=1 (96dpi assumption) rendered waybar/terminal text visibly
  small despite the panel spec suggesting 1x should be fine. Retune per-machine if it looks off.
- `input.lua` — sensitivity=0.35, natural scroll, 3-finger workspace swipe gesture
- `looknfeel.lua` — window opacity 0.80/0.70, blur enabled (passes=9)
- `bindings.lua` — all custom keybinds, Space-menu swap (see below), SUPER+Q
- `autostart.lua` — left at stock template (udiskie autostart is now an Omarchy default)

Then:
- Installs `~/.local/bin/omarchy-hide-all-panels` (SUPER+Q handler, see Quattro section above)
- Copies `omarchy/shell.toml` (`base-size = 16`) — omarchy-shell's own popup panels
  (bluetooth/network/agents) read their font size from here; stock default renders them too
  small on this panel's density, same underlying cause as the monitor scale above.
- `omarchy font set "Adwaita Mono"` — global font (bar, lock screen, menus, everything)
- `omarchy toggle screensaver-off on` — screensaver disabled
- `omarchy toggle idle stay-awake` — auto-lock/logout disabled
- `hyprctl reload`

**Files NOT touched** (Omarchy quattro defaults, left alone): the package-provided
`default.hypr.omarchy` chain, `hyprsunset.conf`, `xdph.conf`, `envs.conf`.

**Keybinding notes:**
- `SUPER+SPACE` and `SUPER+ALT+SPACE` are swapped from quattro's stock default (`hl.unbind` +
  re-bind in `bindings.lua`): plain Space now opens the **Apps menu**, Alt+Space opens the
  **Omarchy menu** (stock ships the other way around).
- `SUPER+RETURN`/`SUPER+SHIFT+RETURN`/`SUPER+ALT+RETURN` (Terminal/Browser/Tmux) are **not**
  rebound here — they're already covered by Omarchy's own defaults
  (`default/hypr/bindings/applications.lua`). Rebinding them causes the key to fire *both*
  binds (two windows open).

### `05-waybar.sh`
1. Installs the `waybar` package if missing (quattro doesn't ship it by default)
2. Copies `config.jsonc`, `style.css`, `scripts/cpu_temp_avg.sh`
3. `omarchy toggle bar-off on` — hides Omarchy's own bar (its process/panels stay alive)
4. Restarts waybar

**Key waybar personalizations:**
- `modules-left`: `custom/omarchy | hyprland/workspaces` (all 9 always visible, via the
  `hyprland.lua` persistent-workspace rules — waybar reads these automatically)
- `modules-right` order: `… voz.agents-icon | bluetooth | network | pulseaudio | cpu | cpu_temp_avg | battery`
- `custom/agents` — robot glyph (`󱚣`); click calls `omarchy-shell shell toggle omarchy.agents`
  to open Omarchy's native Claude Code / Codex usage panel
- `bluetooth`/`network`/`pulseaudio` on-click call each panel's **own dedicated IPC target**
  directly (`omarchy-shell omarchy.bluetooth toggle`, etc.) — not the generic
  `omarchy-shell shell toggle <id>` form, which hits the upstream toggle bug (see Quattro
  section above)
- `custom/cpu_temp_avg` — reads coretemp hwmon, shows average of cores 2-5
- `battery.format-full` — `"󰂅 {capacity}%"` (shows % even at 100%, not just while charging)
- `clock.format` — 12-hour (`{:%A %I:%M %p}`)
- Font — 20px Adwaita Mono in `style.css`, all module margins scaled to match (see the file's
  own comments if adjusting further — everything is proportional to the 20px base)

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
- Terminal fonts (`alacritty.toml`, `kitty.conf`, `ghostty/config`, `foot/foot.ini`) — Adwaita
  Mono, size 13 (tuned for this panel's actual pixel density combined with Hyprland scale=1.1).
  foot/kitty/ghostty also carry a `JetBrainsMono Nerd Font` fallback for icon glyphs (Adwaita
  Mono has none) — Alacritty has no config-level fallback-font mechanism, known gap.
- `gtk-4.0/gtk.css` — Nautilus sidebar row spacing + icon-grid top margin (no gsettings key
  exists for either; this is a targeted CSS override on stable widget names)

Then sets, via `gsettings`:
- `text-scaling-factor = 1.25` — global GTK text scale (combines with Hyprland's 1.1 monitor
  scale for this panel's density)
- `font-name`, `document-font-name`, `monospace-font-name` — bumped a couple points on top of
  the scaling factor
- `org.gnome.nautilus.icon-view default-zoom-level = large`
- `icon-theme = "Yaru-dark-grey-folders"` — **fixes a real bug and a preference**: fresh
  Omarchy installs default to `icon-theme = "Yaru-gray"`, which doesn't exist in the
  `yaru-icon-theme` package actually shipped (only `Yaru`, `Yaru-dark`, and named color
  variants) — every icon is broken until this runs. On top of that, Yaru-dark's folder icons
  are orange, which clashes with the monochrome look, so the script builds a local override
  theme (`~/.local/share/icons/Yaru-dark-grey-folders/`) that inherits everything from
  Yaru-dark except the folder icons, recolored dark grey (`#1a1a1a`→`#404040`, two distinct
  tones so the icon's original shading survives — a single flat color loses all depth).
  Regenerated fresh from the currently-installed Yaru-dark every run via `magick`
  (grayscale → colorize → restore original alpha mask), not stored as static binaries in this
  repo. Depends on `magick`, a baseline Omarchy tool (its own plymouth-theming script uses it
  unconditionally) — not something this repo installs separately.

Then restarts the three `xdg-desktop-portal*` user services so GTK apps opened afterward
reflect the new settings immediately, rather than running on whatever was cached from before
the script ran (these are long-lived session daemons — they don't pick up new gsettings/theme
state on their own).

### `09-verify.sh`
Post-install health checks (all must pass):
1. `hyprctl configerrors` — must be empty
2. `omarchy theme list` — must have >10 themes
3. `omarchy theme current` — must be `Vantablack`
4. Background symlink must exist and resolve
5. `waybar` package installed and process running
6. Omarchy's own bar must be hidden (`omarchy toggle enabled bar-off`)
7. `cpu_temp_avg.sh` must be executable
8. `omarchy-hide-all-panels` (SUPER+Q helper) must be in place and executable
9. 6+ custom Vantablack backgrounds must be present
10. `omarchy font current` must be `Adwaita Mono`
11. Screensaver and idle stay-awake must both be enabled
12. `git user.name` must be set (+ gitignore/hooks/git-purge-ai checks)

### `10-packages.sh`
Installs personal apps with `pacman -S --needed --noconfirm` (skips already-installed).
AUR packages (`google-chrome`, `sioyek-git`, `bibata-cursor-theme`) use `yay`. See
`docs/packages.md` for the full categorized list. (`waybar` itself is installed by
`05-waybar.sh`, not here, since that step already owns "make sure waybar exists and is
configured.")

Then, non-interactively (no credentials/visual input needed, so no reason to leave these
manual):
- `sudo systemctl enable --now docker` + `sudo usermod -aG docker "$USER"` (only re-login for
  the group membership to take effect stays manual)
- `rustup default stable`

---

## Key Personal Settings

| Setting | Value | File |
|---|---|---|
| Theme | Vantablack | via `omarchy theme set Vantablack` |
| Active window opacity | 0.80 | `hypr/looknfeel.lua` |
| Inactive window opacity | 0.70 | `hypr/looknfeel.lua` |
| Blur | enabled, passes=9 | `hypr/looknfeel.lua` |
| Mouse sensitivity | 0.35 | `hypr/input.lua` |
| Natural scroll | enabled | `hypr/input.lua` |
| 3-finger swipe workspace | enabled | `hypr/input.lua` |
| Monitor scale | 1.1 (retune per-machine) | `hypr/monitors.lua` |
| Screensaver | DISABLED | `omarchy toggle screensaver-off on` |
| Auto-lock/logout | DISABLED | `omarchy toggle idle stay-awake` |
| Global font | Adwaita Mono | `omarchy font set "Adwaita Mono"` |
| Terminal font size | 13 (all 4 terminals) + Nerd Font fallback (foot/kitty/ghostty) | `alacritty.toml`/`kitty.conf`/`ghostty/config`/`foot.ini` |
| GTK text scaling | 1.25x | gsettings `text-scaling-factor` |
| Nautilus icon zoom | large | gsettings `org.gnome.nautilus.icon-view` |
| Icon theme | Yaru-dark-grey-folders (grey folders, regenerated each run) | gsettings `icon-theme` |
| omarchy-shell popup font | base-size 16 | `omarchy/shell.toml` |
| Waybar font | 18px Adwaita Mono | `waybar/style.css` |
| App-drawer second-window fix | Files/Power Stats/Disks | `scripts/03-desktop-overrides.sh` |
| Limine boot menu | synced to active theme | `omarchy/hooks/theme-set.d/limine-theme-sync.sh` |
| Clock format | 12-hour | `waybar/config.jsonc` |
| Battery display | icon + % always, even at 100% | `waybar/config.jsonc` |
| CPU temp widget | after cpu icon | `waybar/config.jsonc` |
| Workspaces | 1–9 persistent | `hypr/hyprland.lua` (`hl.workspace_rule`) |
| Space-menu swap | Space=apps, Alt+Space=menu | `hypr/bindings.lua` |
| SUPER+Q | close any open bar panel | `~/.local/bin/omarchy-hide-all-panels` |
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

# Waybar isn't showing changes (no `omarchy restart waybar` under quattro)
pkill -x waybar; setsid uwsm-app -- waybar &>/dev/null &

# omarchy-shell menu-kind plugin change not applying (bar-widget hot-reloads, menu-kind doesn't)
pkill -9 -f "quickshell -n -p"; omarchy-launch-shell &

# A bar panel is stuck open / wrong panel popped on second click
omarchy-hide-all-panels    # or press SUPER+Q

# Background picker
omarchy theme bg next
omarchy theme bg-switcher

# Theme is broken / wrong colors
omarchy theme current               # check active theme
omarchy theme set Vantablack        # re-apply

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
| `~/.local/state/omarchy/current/` | Omarchy theme state — managed by symlinks |
| `~/.config/omarchy/themes/` | Theme files — install via `omarchy theme install <url>` |
| `~/.config/nvim/lazy-lock.json` | Plugin lockfile — regenerated by nvim |
| Any browser profile directories | Personal data, large, volatile |
| Any `.bak.*` files | Backup files from `omarchy refresh`/`omarchy-upgrade-to-quattro` |
| `/usr/share/omarchy/` | Omarchy package tree — never edit, never track |
| `~/.config/omarchy/plugins/*.bak.*` | Backups left by `omarchy plugin remove` |

---

## Fresh Install Sequence (worst-case recovery)

```bash
# 1. Fresh Omarchy install (follow omarchy.org instructions)
# 2. If it's not already quattro, upgrade first:
omarchy-upgrade-to-quattro

# 3. Verify Omarchy is healthy
omarchy debug --no-sudo --print

# 4. Clone this repo
git clone git@github.com:shubhambasak/omarchy-dotfiles.git ~/omarchy-dotfiles-repo

# 5. Install personal apps first (optional but useful for full setup)
bash ~/omarchy-dotfiles-repo/scripts/10-packages.sh

# 6. Apply all personalizations
bash ~/omarchy-dotfiles-repo/install.sh

# 7. Manual steps (need credentials or visual input — everything else is now
#    scripted, including docker enable/group and rustup default stable)
#    - Sign in to 1Password, Vivaldi, Spotify
#    - Re-login for the docker group membership to take effect
#    - Set background via: Omarchy Menu > Styles > Backgrounds, or `omarchy theme bg-switcher`
```
