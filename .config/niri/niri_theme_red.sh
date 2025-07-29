#! /bin/bash

SOCKET="unix:/tmp/kitty-$(id -u)"


mv /home/ptmi/.config/quickshell/Common/Theme.qml /home/ptmi/.config/quickshell/Common/Themes_temp

sed -i '181s/#[^ ]*/#f38ba8"/' /home/ptmi/.config/niri/config.kdl

sed -i '15s/#[^ ]*/#f38ba8",/' /home/ptmi/.config/quickshell/Common/Themes_temp/Theme.qml

mv /home/ptmi/.config/quickshell/Common/Themes_temp/Theme.qml /home/ptmi/.config/quickshell/Common/

sed -i '10s/#[^ ]*/#f38ba8;/' /home/ptmi/.config/rofi/themes/rounded-nord-dark.rasi

sed -i '71s/#[^ ]*/#f38ba8/' /home/ptmi/.config/kitty/current-theme.conf
sed -i '72s/#[^ ]*/#f38ba8/' /home/ptmi/.config/kitty/current-theme.conf
sed -i '12s/#[^ ]*/#eba0ac/' /home/ptmi/.config/kitty/current-theme.conf

kitty @ --to unix:/tmp/kitty-rc set-colors -a -c ~/.config/kitty/current-theme.conf



sudo /usr/bin/papirus-folders -C cat-mocha-red --theme Papirus-Dark

gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"


sed -i '1s/[^ ]*/evening-sky.png/' /home/ptmi/.config/hypr/currentwall.conf


sed -i '6s/#[^ ]*/#f38ba8/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '9s/#[^ ]*/#f38ba8/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '10s/#[^ ]*/#f38ba8/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '109s/#[^ ]*/#f38ba8/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '110s/#[^ ]*/#f38ba8/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '51s/#[^ ]*/#f38ba8/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '55s/#[^ ]*/#f38ba8/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"


# Kill Zen browser (Firefox-based) gracefully
#pkill -f zen-browser

# Wait until fully closed
#while pgrep -f zen-browser > /dev/null; do sleep 0.5; done

# Relaunch Zen Browser
#zen-browser &


WALL="$HOME/Pictures/$(cat ~/.config/hypr/currentwall.conf)"
TEXT_ALPHA="cdd6f4"       # Or read from your currentwall.conf / mocha.conf
ACCENT_ALPHA="f38ba8"
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

sed -i '5s/#[^ ]*/#f38ba8/' /home/ptmi/.config/hypr/hyprlock.conf


sudo /usr/bin/papirus-folders -C cat-mocha-red --theme Papirus-Dark


swww img /home/ptmi/Pictures/evening-sky.png --transition-step 3 --transition-type wipe --transition-fps 144

