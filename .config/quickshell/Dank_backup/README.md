# DankMaterialShell (Quickshell)

A [Quickshell](https://quickshell.org/) built shell designed to be highly functional, in Material 3 style.

Specifically created for [Niri](https://github.com/YaLTeR/niri).

<image>

## Installation

1. Install required dependencies

This shell kinda depends on [Niri](https://github.com/YaLTeR/niri), but only for workspaces and the active window widget in TopBar. So it could be used on any other wayland compositor with minimal changes.

```bash
# 1 --- Material Symbols Font (if not present)
mkdir -p ~/.local/share/fonts && curl -L "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf" -o ~/.local/share/fonts/MaterialSymbolsRounded.ttf && fc-cache -f
# Can also be installed from AUR on arch linux, paru -S ttf-material-symbols-variable-git 

# 2 --- QuickShell (recommended to use a git build)
paru -S quickshell-git
```

2. Install optional dependencies to unlock certain features

| Dependency | Purpose | If Missing |
|------------|---------|------------|
| cava | Equalizer in TopBar uses Audio Data | Equalizer shifts at random |
| cliphist | Allows clipboard history view | No clipboard history view available |
| matugen | Allows dynamic themes based on wallpaper | Just can choose from preconfigured themes instead of dynamic colors |
| ddcutil (or brightnessctl) | Allows controlling brightness of monitors | No Brightness |
| wl-clipboard | Unlocks copy functionality of certain elements, such as process PIDs | No copy |
| swaybg | Wallpaper | Just one wallpaper solution, others will work just not with `set-wallpaper.sh` below |

```bash
# Arch
paru -S ttf-material-symbols-variable-git matugen cliphist cava wl-clipboard ddcutil swaybg
```

**Note on networking:** 

3. Configure SwayBG (If Desired)

```
# Install wallpaper script
sudo cp ./scripts/set-wallpaper.sh /usr/local/bin/set-wallpaper.sh
sudo chmod +x /usr/local/bin/set-wallpaper.sh

# Arch
pacman -S swaybg

# Create service
echo '[Unit]
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=/usr/bin/swaybg -m fill -i "%h/quickshell/current_wallpaper"
Restart=on-failure

[Install]
WantedBy=graphical-session.target' > ~/.config/systemd/user/swaybg.service

# Set a wallpaper
set-wallpaper.sh /path/to/image.jpg

# Enable service
systemctl --user enable --now swaybg.service
```

4. Install DankMaterialShell

```
mkdir -p ~/.config/quickshell
git clone https://github.com/bbedward/DankMaterialShell.git ~/.config/quickshell/DankMaterialShell
```

5. Enable

```
qs -c DankMaterialShell

# In niri config
spawn-at-startup "qs" "-c" "DankMaterialShell"

# Optionally at bindings for spotlight launcher and clipboard history
Mod+Space hotkey-overlay-title="Run an Application: Spotlight" { spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "spotlight" "toggle"; }
Mod+V hotkey-overlay-title="Open Clipboard History" { spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "clipboard" "toggle"; }
```

# Available IPC Events

IPC Events are events that can be triggered with `qs` cli.

```bash
qs -c DankMaterialShell ipc call <target> <function>
```

| Target | Function | Description |
|--------|----------|-------------|
| spotlight | toggle | Toggle spotlight (app launcher) |
| clipboard | toggle | Toggle clipboard history view |
| processlist | toggle | Toggle process list (task manager) |
| wallpaper | refresh | Refresh theme (refreshes theme after wallpaper change) |

## (Optional) Setup Calendar events (Google, Microsoft, other Caldev, etc.)

1. Install [khal](https://github.com/pimutils/khal), [vdirsyncer](https://github.com/pimutils/vdirsyncer), and `aiohttp-oauthlib`

```
# Arch
pacman -S vdirsyncer khal python-aiohttp-oauthlib
```

2. Configure vdirsyncer

Follow the [documentation](https://vdirsyncer.pimutils.org/en/stable/config.html), you will have different steps depending on which calendars you want to sync with.

```
mkdir -p ~/.vdirsyncer

# Create ~/.vdirsyncer/config (a single google calendar would look like)
[general]
status_path = "~/.calendars/status"

[pair personal_sync]
a = "personal"
b = "personallocal"
collections = ["from a", "from b"]
conflict_resolution = "a wins"
metadata = ["color"]

[storage personal]
type = "google_calendar"
token_file = "~/.vdirsyncer/google_calendar_token"
client_id = "...."
client_secret = "...."

[storage personallocal]
type = "filesystem"
path = "~/.calendars/Personal"
fileext = ".ics"

# Sync
vdirsyncer sync

# Create crontab
crontab -e 
# e.g., this syncs every 5 minutes
*/5 * * * * /usr/bin/vdirsyncer sync
```

3. Configure khal

```
# Run this
khal configure

# Choose option 2 for month/day/year
# Time format, doesnt matter
# Choose option 1 for use calendar alreayd on this computer
```

