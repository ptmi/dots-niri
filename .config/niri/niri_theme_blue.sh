#! /bin/bash

SOCKET="unix:/tmp/mykitty"

#Quickshell colors
mv /home/ptmi/.config/quickshell/DankMaterialShell/Common/Theme.qml /home/ptmi/.config/quickshell/DankMaterialShell/Common/Themes_temp
sed -i '15s/#[^ ]*/#89dceb",/' /home/ptmi/.config/quickshell/DankMaterialShell/Common/Themes_temp/Theme.qml
mv /home/ptmi/.config/quickshell/DankMaterialShell/Common/Themes_temp/Theme.qml /home/ptmi/.config/quickshell/DankMaterialShell/Common/


#Niri colors
sed -i '181s/#[^ ]*/#89dceb"/' /home/ptmi/.config/niri/config.kdl

#Rofi colors
sed -i '10s/#[^ ]*/#89dceb;/' /home/ptmi/.config/rofi/themes/rounded-nord-dark.rasi
sed -i '20s/#[^ ]*/#89dceb;/' /home/ptmi/.config/rofi/wallSelect.rasi


#Kitty colors
sed -i '71s/#[^ ]*/#89dceb/' /home/ptmi/.config/kitty/current-theme.conf
sed -i '72s/#[^ ]*/#89dceb/' /home/ptmi/.config/kitty/current-theme.conf
sed -i '12s/#[^ ]*/#94e2d5/' /home/ptmi/.config/kitty/current-theme.conf

kitty @ --to unix:/tmp/kitty-rc set-colors -a -c ~/.config/kitty/current-theme.conf

sed -i '5s/#[^ ]*/#89dceb/' /home/ptmi/.config/hypr/hyprlock.conf
sed -i '6s/#[^ ]*/#89dceb/' /home/ptmi/.config/hypr/hyprlock.conf


sed -i '1s/[^ ]*/blue.jpg/' /home/ptmi/.config/hypr/currentwall.conf


sudo /usr/bin/papirus-folders -C cat-mocha-sky --theme Papirus-Dark

gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

sed -i '6s/#[^ ]*/#89dceb/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '9s/#[^ ]*/#89dceb/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '10s/#[^ ]*/#89dceb/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '109s/#[^ ]*/#89dceb/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '110s/#[^ ]*/#89dceb/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '51s/#[^ ]*/#89dceb/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"
sed -i '55s/#[^ ]*/#89dceb/' "/home/ptmi/.zen/fwj4g34p.Default (release)/chrome/userChrome.css"


WALL="$HOME/Pictures/$(cat ~/.config/hypr/currentwall.conf)"
TEXT_ALPHA="cdd6f4"       # Or read from your currentwall.conf / mocha.conf
ACCENT_ALPHA="89dceb"
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

sed -i '5s/#[^ ]*/#89dceb/' /home/ptmi/.config/hypr/hyprlock.conf


qs -c /home/ptmi/.config/quickshell/DankMaterialShell ipc call wallpaper set /home/ptmi/Pictures/blue.jpg




