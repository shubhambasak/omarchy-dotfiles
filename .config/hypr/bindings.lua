-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Application bindings
-- Terminal / Tmux / Browser on RETURN already come from Omarchy's own
-- defaults (bindings/applications.lua) - do not rebind them here or the key
-- fires both binds and opens two windows.
o.bind("SUPER + SHIFT + F", "File manager", "uwsm-app -- nautilus --new-window")
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", 'uwsm-app -- nautilus --new-window "$(omarchy-cmd-terminal-cwd)"')
o.bind("SUPER + SHIFT + B", "Browser", "omarchy-launch-browser")
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", "omarchy-launch-browser --private")
o.bind("SUPER + SHIFT + M", "Music", "omarchy-launch-or-focus spotify")
o.bind("SUPER + SHIFT + ALT + M", "Music TUI", "omarchy-launch-or-focus-tui cliamp")
o.bind("SUPER + SHIFT + N", "Editor", "omarchy-launch-editor")
o.bind("SUPER + SHIFT + D", "Docker", "omarchy-launch-tui lazydocker")
o.bind("SUPER + SHIFT + G", "Signal", 'omarchy-launch-or-focus ^signal$ "uwsm-app -- signal-desktop"')
o.bind("SUPER + SHIFT + O", "Obsidian", 'omarchy-launch-or-focus ^obsidian$ "uwsm-app -- obsidian"')
o.bind("SUPER + SHIFT + W", "Typora", "uwsm-app -- typora --enable-wayland-ime")
o.bind("SUPER + SHIFT + SLASH", "Passwords", "uwsm-app -- 1password")

-- If your web app url contains #, escaping is not needed here (unlike hyprlang comments).
o.bind("SUPER + SHIFT + A", "ChatGPT", 'omarchy-launch-webapp "https://chatgpt.com"')
o.bind("SUPER + SHIFT + ALT + A", "Grok", 'omarchy-launch-webapp "https://grok.com"')
o.bind("SUPER + SHIFT + C", "Calendar", 'omarchy-launch-webapp "https://app.hey.com/calendar/weeks/"')
o.bind("SUPER + SHIFT + E", "Email", 'omarchy-launch-webapp "https://app.hey.com"')
o.bind("SUPER + SHIFT + Y", "YouTube", 'omarchy-launch-webapp "https://youtube.com/"')
o.bind("SUPER + SHIFT + ALT + G", "WhatsApp", 'omarchy-launch-or-focus-webapp WhatsApp "https://web.whatsapp.com/"')
o.bind("SUPER + SHIFT + CTRL + G", "Google Messages", 'omarchy-launch-or-focus-webapp "Google Messages" "https://messages.google.com/web/conversations"')
o.bind("SUPER + SHIFT + P", "Google Photos", 'omarchy-launch-or-focus-webapp "Google Photos" "https://photos.google.com/"')
o.bind("SUPER + SHIFT + X", "X", 'omarchy-launch-webapp "https://x.com/"')
o.bind("SUPER + SHIFT + ALT + X", "X Post", 'omarchy-launch-webapp "https://x.com/compose/post"')

-- Add extra bindings
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Swap the default Space bindings: app drawer on plain Super+Space,
-- Omarchy menu on Super+Alt+Space (defaults ship the other way around).
hl.unbind("SUPER + SPACE")
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SPACE", "Apps menu", "omarchy-menu toggle apps")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")

-- Close any open bar panel (bluetooth, wifi, audio, agents, etc). Safety
-- net for a toggle bug where clicking the same bar icon twice sometimes
-- opens a different panel instead of closing the current one.
o.bind("SUPER + Q", "Close bar panel", "omarchy-hide-all-panels")

-- Logitech MX Keys
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
