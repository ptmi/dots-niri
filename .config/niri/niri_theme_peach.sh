#! /bin/bash

KITTY_THEME_FILE="/home/ptmi/.config/kitty/current-theme.conf"
SOCKET="unix:/tmp/kitty-$(id -u)"

#mv /home/ptmi/.config/niri/Themes/config.kdl /home/ptmi/.config/niri/Themes_temp
#mv /home/ptmi/.config/niri/config.kdl /home/ptmi/.config/niri/Themes/
#mv /home/ptmi/.config/niri/Themes_temp/config.kdl /home/ptmi/.config/niri
mv /home/ptmi/.config/quickshell/Common/Theme.qml /home/ptmi/.config/quickshell/Common/Themes_temp

sed -i '181s/#[^ ]*/#fab387"/' /home/ptmi/.config/niri/config.kdl

sed -i '15s/#[^ ]*/#fab387",/' /home/ptmi/.config/quickshell/Common/Themes_temp/Theme.qml

mv /home/ptmi/.config/quickshell/Common/Themes_temp/Theme.qml /home/ptmi/.config/quickshell/Common/

sed -i '10s/#[^ ]*/#fab387;/' /home/ptmi/.config/rofi/themes/rounded-nord-dark.rasi
sed -i '20s/#[^ ]*/#fab387;/' /home/ptmi/.config/rofi/wallSelect.rasi



sed -i '71s/#[^ ]*/#fab387/' /home/ptmi/.config/kitty/current-theme.conf
sed -i '72s/#[^ ]*/#fab387/' /home/ptmi/.config/kitty/current-theme.conf
sed -i '12s/#[^ ]*/#f9e2af/' /home/ptmi/.config/kitty/current-theme.conf

kitty @ --to unix:/tmp/kitty-rc set-colors -a -c ~/.config/kitty/current-theme.conf

sed -i '5s/#[^ ]*/#fab387/' /home/ptmi/.config/hypr/hyprlock.conf

sed -i '1s/[^ ]*/result.png/' /home/ptmi/.config/hypr/currentwall.conf

gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"


sed -i '6s/#[^ ]*/#fab387/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '9s/#[^ ]*/#fab387/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '10s/#[^ ]*/#fab387/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '109s/#[^ ]*/#fab387/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '110s/#[^ ]*/#fab387/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '51s/#[^ ]*/#fab387/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '55s/#[^ ]*/#fab387/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"

# Kill Zen browser (Firefox-based) gracefully
#pkill -f zen-browser

# Wait until fully closed
#while pgrep -f zen-browser > /dev/null; do sleep 0.5; done

# Relaunch Zen Browser
#zen-browser &


WALL="$HOME/Pictures/$(cat ~/.config/hypr/currentwall.conf)"
TEXT_ALPHA="cdd6f4"       # Or read from your currentwall.conf / mocha.conf
ACCENT_ALPHA="fab387"
USER_NAME="$(ptmi)"

# Template and output paths
TEMPLATE="$HOME/.config/hypr/hyprlock.conf.template"
FINAL="$HOME/.config/hypr/hyprlock.conf"
# Define values


# Replace placeholders in your template
sed -e "s|__TEXT_ALPHA__|$TEXT_ALPHA|g" \
    -e "s|__ACCENT_ALPHA__|$ACCENT_ALPHA|g" \
    -e "s|__USER__|$USER_NAME|g" \
    -e "s|__WALLPAPER_PATH__|$WALL|g" \
    "$TEMPLATE" > "$FINAL"

sed -i '5s/#[^ ]*/#fab387/' /home/ptmi/.config/hypr/hyprlock.conf


sudo /usr/bin/papirus-folders -C cat-mocha-peach --theme Papirus-Dark


swww img /home/ptmi/Pictures/result.png --transition-step 3 --transition-type wipe --transition-fps 144

