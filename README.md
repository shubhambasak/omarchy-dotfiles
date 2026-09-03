# Omarchy Dotfiles (Shubham Basak)

Personal customizations layered on top of [Omarchy quattro](https://omarchy.org/)
(Arch + Hyprland, package-backed). See `CLAUDE.md` for the full picture of what changed
between Omarchy 3.x and quattro and why — this file is the quick reference.

## What this repo tracks

Only **personally customized** files — not Omarchy's managed state, not browser data,
not app caches. Omarchy's own theme management system (`~/.local/state/omarchy/current/`,
`~/.config/omarchy/themes/`) is intentionally excluded; it is reproduced via commands.

```
.config/
├── alacritty/, kitty/, ghostty/, foot/   # Terminal fonts (Adwaita Mono, size 13 + Nerd Font
│                                          # icon fallback on foot/kitty/ghostty — see below)
├── git/config                # Git identity + aliases
├── gtk-4.0/gtk.css            # Nautilus sidebar spacing + icon-grid top margin
├── hypr/
│   ├── autostart.lua          # Extra startup processes (stock template — udiskie is now an Omarchy default)
│   ├── bindings.lua           # Keybinding overrides + Space-menu swap + SUPER+Q
│   ├── hyprland.lua           # Entrypoint — loads overrides + 9 persistent workspaces
│   ├── input.lua              # Touchpad: sensitivity, natural scroll, gestures
│   ├── looknfeel.lua          # Window opacity (0.80/0.70) + blur
│   └── monitors.lua           # scale=1.1 (retune per-machine if it looks off)
├── nvim/                      # LazyVim config + custom plugins & snippets
├── omarchy/
│   ├── backgrounds/
│   │   └── vantablack/        # Custom wallpapers for Vantablack theme
│   ├── hooks/theme-set.d/
│   │   └── limine-theme-sync.sh  # Recolors the Limine boot menu on every theme change
│   └── shell.toml             # omarchy-shell popup panel (bluetooth/network/agents) font size
├── starship.toml              # Shell prompt
├── tmux/tmux.conf
└── waybar/
    ├── config.jsonc           # Bar layout (cpu temp, agent icon, 9 workspaces, 12h clock)
    ├── scripts/
    │   └── cpu_temp_avg.sh    # CPU average temperature script
    └── style.css              # Bar styling (18px Adwaita Mono)
.local/bin/omarchy-hide-all-panels  # SUPER+Q handler — force-closes any open bar panel
```

**Nerd Font icon fallback:** `Adwaita Mono` has no icon glyphs, so LazyVim/waybar icons would
render as blank boxes without a fallback font for the Private-Use-Area codepoints Nerd Fonts
use. foot and kitty (`symbol_map`) and ghostty (a second `font-family` line) carry an explicit
`JetBrainsMono Nerd Font` fallback; Alacritty has no config-level fallback-font mechanism, so
it doesn't get one — a known gap, not yet verified whether its automatic system fallback covers
these codepoints.

**Launch-or-focus bug workaround:** `scripts/03-desktop-overrides.sh` installs user-level
`.desktop` overrides (generated from the live system files, not stored statically) for Files,
Power Statistics, and Disks — all three ship `DBusActivatable=true`, and Omarchy's app-drawer
launches via `gtk-launch`, which for an already-running D-Bus-activatable app just re-presents
the existing window instead of opening a new one. The override strips that one line.

**Waybar, not Omarchy's new bar:** quattro ships its own Quickshell-based bar by default;
this repo reinstalls real waybar instead (a narrow app-drawer and an upstream toggle bug in
the new bar's panel-tracking made waybar the better fit). Everything else — idle/lock,
notifications, the app launcher — stays on Omarchy's new shell; only its *bar* is hidden.
Full explanation in `CLAUDE.md`.

## Restoring on a fresh Omarchy quattro install

```bash
# 1. If not already quattro:
omarchy-upgrade-to-quattro

# 2. Clone this repo
git clone https://github.com/shubhambasak/omarchy-dotfiles.git ~/omarchy-dotfiles-repo

# 3. Run the installer
bash ~/omarchy-dotfiles-repo/install.sh
```

That's it — `install.sh` runs every step in `scripts/`, including reinstalling the `waybar`
package (quattro doesn't ship it by default), setting the font/screensaver/idle behavior via
`omarchy` commands, and a `09-verify.sh` health check at the end. Re-run any single step with
`bash scripts/05-waybar.sh ~/omarchy-dotfiles-repo`.

## Key personal settings

| Setting | Value | File |
|---|---|---|
| Theme | Vantablack | `omarchy theme set Vantablack` |
| Window opacity (active/inactive) | 0.80 / 0.70 | `hypr/looknfeel.lua` |
| Blur | enabled, passes=9 | `hypr/looknfeel.lua` |
| Mouse sensitivity | 0.35 | `hypr/input.lua` |
| Natural scroll + 3-finger swipe | enabled | `hypr/input.lua` |
| Monitor scale | 1.1 (retune per-machine) | `hypr/monitors.lua` |
| Screensaver / auto-lock | disabled | `omarchy toggle screensaver-off on` / `omarchy toggle idle stay-awake` |
| Global font | Adwaita Mono | `omarchy font set "Adwaita Mono"` |
| Terminal font size | 13, all 4 terminals + Nerd Font fallback (foot/kitty/ghostty) | `alacritty.toml`/`kitty.conf`/`ghostty/config`/`foot.ini` |
| GTK scaling / Nautilus zoom | 1.25x / large | gsettings, set in `08-misc.sh` |
| Icon theme | Yaru-dark-grey-folders (grey folders, not Yaru's orange; regenerated each run) | gsettings, built by `08-misc.sh` |
| omarchy-shell popup panel font | base-size 16 | `omarchy/shell.toml` |
| Clock format | 12-hour | `waybar/config.jsonc` |
| Battery display | icon + %, even at 100% | `waybar/config.jsonc` |
| Waybar font | 18px Adwaita Mono | `waybar/style.css` |
| Persistent workspaces | 1–9 | `hypr/hyprland.lua` |
| Space-menu swap | Space=apps, Alt+Space=menu | `hypr/bindings.lua` |
| SUPER+Q | close any open bar panel | `.local/bin/omarchy-hide-all-panels` |
| App-drawer second-window fix | Files/Power Stats/Disks | `scripts/03-desktop-overrides.sh` |
| Limine boot menu | synced to active theme's colors | `omarchy/hooks/theme-set.d/limine-theme-sync.sh` |

## What NOT to commit to this repo

- `~/.local/state/omarchy/current/` — Omarchy manages this via symlinks
- `~/.config/omarchy/themes/` — use `omarchy theme install <url>` instead
- Any browser profile data (Chromium, Cursor, Vivaldi, etc.)
- Any `.bak.*` files created by `omarchy refresh` / `omarchy-upgrade-to-quattro` / `omarchy plugin remove`
- `~/.config/nvim/lazy-lock.json` — regenerated by nvim on startup
- `/usr/share/omarchy/` — Omarchy's package tree, never edit or track
