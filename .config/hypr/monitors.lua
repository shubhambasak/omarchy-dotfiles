-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
-- 1.1 measured correct on this 1080p 14" panel — scale=1 rendered at a flat
-- 96dpi assumption and came out visibly small (waybar/terminal text) despite
-- the panel's on-paper spec suggesting 1x should be fine. Retune per-machine
-- if this ever looks off on different hardware.
local omarchy_monitor_scale = 1.1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
