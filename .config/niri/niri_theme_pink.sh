#! /bin/bash

SOCKET="unix:/tmp/mykitty"

#Quickshell colors
mv /home/ptmi/.config/quickshell/dms/Common/Theme.qml /home/ptmi/.config/quickshell/dms/Common/Themes_temp
mv /home/ptmi/.config/quickshell/dms/Common/StockThemes.js /home/ptmi/.config/quickshell/dms/Common/Themes_temp
sed -i '8s/#[^ ]*/#f5c2e7",/' /home/ptmi/.config/quickshell/dms/Common/Themes_temp/StockThemes.js
mv /home/ptmi/.config/quickshell/dms/Common/Themes_temp/StockThemes.js /home/ptmi/.config/quickshell/dms/Common/
mv /home/ptmi/.config/quickshell/dms/Common/Themes_temp/Theme.qml /home/ptmi/.config/quickshell/dms/Common/


#Niri colors
sed -i '181s/#[^ ]*/#f5c2e7"/' /home/ptmi/.config/niri/config.kdl

#Rofi colors
sed -i '10s/#[^ ]*/#f5c2e7;/' /home/ptmi/.config/rofi/themes/rounded-nord-dark.rasi
sed -i '20s/#[^ ]*/#f5c2e7;/' /home/ptmi/.config/rofi/wallSelect.rasi

#Kitty colors
sed -i '71s/#[^ ]*/#f5c2e7/' /home/ptmi/.config/kitty/current-theme.conf
sed -i '72s/#[^ ]*/#f5c2e7/' /home/ptmi/.config/kitty/current-theme.conf
sed -i '12s/#[^ ]*/#cba6f7/' /home/ptmi/.config/kitty/current-theme.conf

kitty @ --to unix:/tmp/kitty-rc set-colors -a -c ~/.config/kitty/current-theme.conf

sed -i '5s/#[^ ]*/##f5c2e7/' /home/ptmi/.config/hypr/hyprlock.conf
sed -i '6s/#[^ ]*/##f5c2e7/' /home/ptmi/.config/hypr/hyprlock.conf


sed -i '1s/[^ ]*/pink_bike.jpg/' /home/ptmi/.config/hypr/currentwall.conf


sudo /usr/bin/papirus-folders -C cat-mocha-pink --theme Papirus-Dark

gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

sed -i '6s/#[^ ]*/#f5c2e7/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '9s/#[^ ]*/#f5c2e7/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '10s/#[^ ]*/#f5c2e7/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '109s/#[^ ]*/#f5c2e7/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '110s/#[^ ]*/#f5c2e7/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '51s/#[^ ]*/#f5c2e7/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '55s/#[^ ]*/#f5c2e7/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"


WALL="$HOME/Pictures/$(cat ~/.config/hypr/currentwall.conf)"
TEXT_ALPHA="cdd6f4"       # Or read from your currentwall.conf / mocha.conf
ACCENT_ALPHA="f5c2e7"
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

sed -i '5s/#[^ ]*/#f5c2e7/' /home/ptmi/.config/hypr/hyprlock.conf


swww img /home/ptmi/Pictures/pink_bike.jpg --transition-step 3 --transition-type wipe --transition-fps 144


qs -c /home/ptmi/.config/quickshell/dms ipc call wallpaper set /home/ptmi/Pictures/pink_bike.jpg

