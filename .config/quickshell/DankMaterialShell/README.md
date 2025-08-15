# DankMaterialShell

<div align=center>

![GitHub last commit](https://img.shields.io/github/last-commit/AvengeMedia/DankMaterialShell?style=for-the-badge&labelColor=101418&color=9ccbfb)
![GitHub stars](https://img.shields.io/github/stars/AvengeMedia/DankMaterialShell?style=for-the-badge&labelColor=101418&color=ffd700)
![GitHub License](https://img.shields.io/github/license/AvengeMedia/DankMaterialShell?style=for-the-badge&labelColor=101418&color=b9c8da)
![GitHub repo size](https://img.shields.io/github/repo-size/AvengeMedia/DankMaterialShell?style=for-the-badge&labelColor=101418&color=d3bfe6)

</div>

A modern Wayland desktop shell built with [Quickshell](https://quickshell.org/) and designed specifically for the [niri](https://github.com/YaLTeR/niri) compositor. Features Material 3 design principles with a heavy focus on functionality and customizability.

## Screenshots

<div align="center">
<div style="max-width: 700px; margin: 0 auto;">

https://github.com/user-attachments/assets/5ad934bb-e7aa-4c04-8d40-149181bd2d29

</div>
</div>

<details><summary><strong>View More Screenshots</strong></summary>

<br>

<div align="center">

### Desktop Overview

<img src="https://github.com/user-attachments/assets/203a9678-c3b7-4720-bb97-853a511ac5c8" width="600" alt="DankMaterialShell Desktop" />

### Application Launcher

<img src="https://github.com/user-attachments/assets/2da00ea1-8921-4473-a2a9-44a44535a822" width="450" alt="Spotlight Launcher" />

### System Monitor

<img src="https://github.com/user-attachments/assets/b3c817ec-734d-4974-929f-2d11a1065349" width="600" alt="System Monitor" />

### Widget Customization

<img src="https://github.com/user-attachments/assets/903f7c60-146f-4fb3-a75d-a4823828f298" width="500" alt="Widget Customization" />

### Lock Screen

<img src="https://github.com/user-attachments/assets/3fa07de2-c1b0-4e57-8f25-3830ac6baf4f" width="600" alt="Lock Screen" />

### Dynamic Theming

<img src="https://github.com/user-attachments/assets/1994e616-f9d9-424a-9f60-6f06708bf12e" width="700" alt="Auto Theme" />

### Notification Center

<img src="https://github.com/user-attachments/assets/07cbde9a-0242-4989-9f97-5765c6458c85" width="350" alt="Notification Center" />

### Dock

<img src="https://github.com/user-attachments/assets/e6999daf-f7bf-4329-98fa-0ce4f0e7219c" width="400" alt="Dock" />

</div>

</details>

## What's Inside

**Core Widgets:**

- **TopBar**: fully customizable bar where widgets can be added, removed, and re-arranged.
  - **App Launcher** with fuzzy search, categories, and auto-sorting by most used apps.
  - **Workspace Switcher** Dynamically resizing niri workspace switcher.
  - **Focused Window** Displays the currently focused window app name and title.
  - **Media Player** Short form media player with equalizer, song title, and controls.
  - **Clock** Clock and date widget
  - **Weather** Weather widget with customizable location
  - **System Tray** System tray applets with context menus.
  - **Process Monitor** CPU/Ram usage indicators - with a detailed process list PopUp
  - **Power/Battery** Power/Battery widget for battery metrics and power profile changing.
  - **Notifications** Notification bell with a notification center popup
  - **Control Center** High-level view of network, bluetooth, and audio status
- **Spotlight Launcher** A central app launcher/search that can be triggered via an IPC keybinding.
- **Central Command** A combined music, weather, calendar, and events PopUp.
- **Process List** A process list, with system metrics and information. More detailed modal available via IPC.
- **Notification Center** A center for notifications that has support for grouping.
- **Dock** A dock with pinned apps support, recent apps support, and currently running application support.
- **Control Center** A full control center with user profile information, network, bluetooth, audio input/output, and display controls.
- **Lock Screen** Using quickshell's WlSessionLock

**Features:**

- Dynamic wallpaper-based theming with matugen integration
- Numerous IPCs to trigger actions and open various modals.
- Calendar integration with [khal](https://github.com/pimutils/khal)
- Audio/media controls
- Grouped notifications
- Brightness control for internal and external displays
- Qt and GTK app theming synchronization, as well as [Ghostty](https://ghostty.org/) auto-theme support.

## Installation

### Quick Start

\*If you do not already have niri, see [#]

**Dependencies:**

```bash
# Arch Linux
paru -S quickshell-git ttf-material-symbols-variable-git inter-font ttf-fira-code

# Fedora
sudo dnf copr enable errornointernet/quickshell && sudo dnf install quickshell-git rsms-inter-fonts fira-code-fonts
# Install icon fonts manually
mkdir -p ~/.local/share/fonts
curl -L "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf" -o ~/.local/share/fonts/MaterialSymbolsRounded.ttf
fc-cache -f
```

**Get the shell:**

```bash
# Arch linux available via AUR
paru -S dankmaterialshell-git

# Manual install
mkdir -p ~/.config/quickshell
git clone https://github.com/AvengeMedia/DankMaterialShell.git ~/.config/quickshell/DankMaterialShell
qs -c DankMaterialShell
```

### Detailed Setup

<details><summary>Font Installation</summary>

**Material Symbols (Required):**

```bash
# Manual installation
mkdir -p ~/.local/share/fonts
curl -L "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf" -o ~/.local/share/fonts/MaterialSymbolsRounded.ttf
fc-cache -f

# Arch Linux
paru -S ttf-material-symbols-variable-git
```

**Typography (Recommended):**

```bash
# Inter Variable Font
curl -L "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip" -o /tmp/Inter.zip
unzip -j /tmp/Inter.zip "InterVariable.ttf" "InterVariable-Italic.ttf" -d ~/.local/share/fonts/
rm /tmp/Inter.zip && fc-cache -f

# Fira Code
curl -L "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -o /tmp/FiraCode.zip
unzip -j /tmp/FiraCode.zip "ttf/*.ttf" -d ~/.local/share/fonts/
rm /tmp/FiraCode.zip && fc-cache -f
```

</details>

<details><summary>Optional Features</summary>

**Enhanced Functionality:**

```bash
# Install dgop on any distro (requires go 1.23+):
git clone https://github.com/AvengeMedia/dgop.git && cd dgop
make && sudo make install
```

```bash
# Arch Linux
pacman -S cava wl-clipboard cliphist brightnessctl
paru -S matugen dgop

# Fedora
sudo dnf install cava wl-clipboard brightnessctl
sudo dnf copr enable wef/cliphist && sudo dnf install cliphist
sudo dnf copr enable heus-sueh/packages && sudo dnf install matugen
```

**What you get:**

- `dgop`: Ability to have system resource widgets, process list modal, and temperature monitoring.
- `matugen`: Wallpaper-based dynamic theming
- `brightnessctl`: Backlight and LED brightness control
- `wl-clipboard`: Required for copying various elements to clipboard.
- `cava`: Audio visualizer
- `cliphist`: Clipboard history
- `gammastep`: Night mode support

</details>

## Usage

### Niri Integration

Add to your niri config

```bash
// Required for clipboard history integration
spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"

// Recommended (must install polkit-mate before hand) for elevation prompts
spawn-at-startup "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"
// This may be a different path on different distributions, the above is for the arch linux mate-polkit package

// Starts DankShell
spawn-at-startup "qs" "-c" "DankMaterialShell"

// Dank keybinds
// 1. These should not be in conflict with any pre-existing keybindings
// 2. You need to merge them with your existing config if you want to use these
// 3. You can change the keys to whatever you want, if you prefer something different
// 4. For the increment/decrement ones you can change the steps to whatever you like too
binds {
   Mod+Space hotkey-overlay-title="Application Launcher" {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "spotlight" "toggle";
   }
   Mod+V hotkey-overlay-title="Clipboard Manager" {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "clipboard" "toggle";
   }
   Mod+M hotkey-overlay-title="Task Manager" {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "processlist" "toggle";
   }
   Mod+N hotkey-overlay-title="Notification Center" {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "notifications" "toggle";
   }
   Mod+Comma hotkey-overlay-title="Settings" {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "settings" "toggle";
   }
   Super+Alt+L hotkey-overlay-title="Lock Screen" {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "lock" "lock";
   }
   XF86AudioRaiseVolume allow-when-locked=true {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "audio" "increment" "3";
   }
   XF86AudioLowerVolume allow-when-locked=true {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "audio" "decrement" "3";
   }
   XF86AudioMute allow-when-locked=true {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "audio" "mute";
   }
   XF86AudioMicMute allow-when-locked=true {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "audio" "micmute";
   }
   XF86MonBrightnessUp allow-when-locked=true {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "brightness" "increment" "5" "";
   }
   // You can override the default device for e.g. keyboards by adding the device name to the last param
   XF86MonBrightnessDown allow-when-locked=true {
      spawn "qs" "-c" "DankMaterialShell" "ipc" "call" "brightness" "decrement" "5" "";
   }
}
```

### IPC Commands

Control everything from the command line, or via keybinds:

```bash
# Audio control
qs -c DankMaterialShell ipc call audio setvolume 50
qs -c DankMaterialShell ipc call audio mute

# Launch applications
qs -c DankMaterialShell ipc call spotlight toggle
qs -c DankMaterialShell ipc call processlist toggle

# System control
qs -c DankMaterialShell ipc call wallpaper set /path/to/image.jpg
qs -c DankMaterialShell ipc call theme toggle
qs -c DankMaterialShell ipc call lock lock

# Media control
qs -c DankMaterialShell ipc call mpris playPause
qs -c DankMaterialShell ipc call mpris next
```

## Theming

### System App Integration

There's two toggles in the appearance section of settings, for GTK and QT apps.

These settings will override some local GTK and QT configuration files, you can still integrate auto-theming if you do not wish DankShell to mess with your QTCT/GTK files.

No matter what when matugen is enabled the files will be created on wallpaper changes:

- ~/.config/gtk-3.0/dank-colors.css
- ~/.config/gtk-4.0/dank-colors.css
- ~/.config/qt6ct/colors/matugen.conf
- ~/.config/qt5ct/colors/matugen.conf

If you do not like our theme path, you can integrate this with other GTK themes, matugen themes, etc.

**GTK Apps:**

1. Install [Colloid](https://github.com/vinceliuice/Colloid-gtk-theme)

Colloid is a hard requirement for the auto-theming because of how it integrates with colloid css files, however you can integrate auto-theming with other themes, you just have to do it manually (so leave the toggle OFF in settings)

It will still create `~/.config/gtk-3.0/4.0/dank-colors.css` on theme updates, these you can import into other compatible GTK themes.

```bash
# Some default install settings for colloid
./install.sh -s standard -l --tweaks normal
```

Configure in `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`:

```ini
[Settings]
gtk-theme-name=Colloid
```

**Qt Apps:**

You have **two** paths for QT theming, first path is to use **gtk3**. To do that, add the following to your niri config.

```kdl
environment {
  // Add to existing environment block
  QT_QPA_PLATFORMTHEME "gtk3"
  QT_QPA_PLATFORMTHEME_QT6 "gtk3"
}
```

**Done** - if you're not happy with this and wish to use Breeze or another QT theme then continue on.

1. Install qt6ct and qt5ct

```bash
# Arch
pacman -S qt5ct qt6ct
# Fedora
dnf install qt5ct qt6ct
```

2. Configure Environment in niri

```kdl
  // Add to existing environment block
  QT_QPA_PLATFORMTHEME "qt5ct"
  QT_QPA_PLATFORMTHEME_QT6 "qt6ct"
```

You'll have to restart your session for themes to take effect.

### Terminal Integration

**Ghostty users** can add automatic color theming:

```bash
echo "config-file = ./config-dankcolors" >> ~/.config/ghostty/config
```

## Calendar Setup

Sync your caldev compatible calendar (Google, Office365, etc.) for dashboard integration:

<details><summary>Configuration Steps</summary>

**Install dependencies:**

```bash
# Arch
pacman -S vdirsyncer khal python-aiohttp-oauthlib

# Fedora
sudo dnf install python3-vdirsyncer khal python3-aiohttp-oauthlib
```

**Configure vdirsyncer** (`~/.vdirsyncer/config`):

```ini
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
client_id = "your_client_id"
client_secret = "your_client_secret"

[storage personallocal]
type = "filesystem"
path = "~/.calendars/Personal"
fileext = ".ics"
```

**Setup sync:**

```bash
vdirsyncer sync
khal configure

# Auto-sync every 5 minutes
crontab -e
# Add: */5 * * * * /usr/bin/vdirsyncer sync
```

</details>

## Configuration

All settings are configurable in `~/.config/DankMaterialShell/settings.json`, or more intuitively the built-in settings modal.

**Key configuration areas:**

- Widget positioning and behavior
- Theme and color preferences
- Time format, weather units and location
- Light/Dark modes
- Wallpaper and Profile picture
- Dock enable/disable and various tunes.

## Troubleshooting

**Common issues:**

- **Missing icons:** Verify Material Symbols font installation with `fc-list | grep Material`
- **No dynamic theming:** Install matugen and enable in settings
- **Qt apps not themed:** Configure qt5ct/qt6ct and set QT_QPA_PLATFORMTHEME
- **Calendar not syncing:** Check vdirsyncer credentials and network connectivity

**Getting help:**

- Check the [issues](https://github.com/AvengeMedia/DankMaterialShell/issues) for known problems
- Share logs from `qs -c DankMaterialShell` for debugging
- Join the niri community for compositor-specific questions

## Contributing

DankMaterialShell welcomes contributions! Whether it's bug fixes, new widgets, theme improvements, or documentation updates - all help is appreciated.

**Areas that need attention:**

- More widget options and customization
- Additional compositor compatibility
- Performance optimizations
- Documentation and examples

## Credits

- [quickshell](https://quickshell.org/) the core of what makes a shell like this possible.
- [niri](https://github.com/YaLTeR/niri) for the awesome scrolling compositor.
- [soramanew](https://github.com/soramanew) who built [caelestia](https://github.com/caelestia-dots/shell) which served as inspiration and guidance for many dank widgets.
- [end-4](https://github.com/end-4) for [dots-hyprland](https://github.com/end-4/dots-hyprland) which also served as inspiration and guidance for many dank widgets.
