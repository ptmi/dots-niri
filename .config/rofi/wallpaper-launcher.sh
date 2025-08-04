#!/bin/bash
#  ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗
#  ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
#  ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
#  ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
#  ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
#   ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
#
#  ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
#  ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗
#  ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝
#  ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗
#  ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║
#  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
#	originally written by: gh0stzk - https://github.com/gh0stzk/dotfiles
#	rewritten for hyprland by :	 develcooking - https://github.com/develcooking/hyprland-dotfiles
#	Info    - This script runs the rofi launcher, to select
#             the wallpapers included in the theme you are in.



# Set some variables
wall_dir="/home/ptmi/Pictures/Wallpapers"
cache_dir="/home/ptmi/.cache/thumbnails/wal_selector"
rofi_command="rofi -dmenu -config /home/ptmi/.config/rofi/wallSelect.rasi -show-icons"

if [ ! -d "${cache_dir}" ] ; then
        mkdir -p "${cache_dir}"
fi



for imagen in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
	if [ -f "$imagen" ]; then
		filename=$(basename "$imagen")
			if [ ! -f "${cache_dir}/${filename}" ] ; then
				magick "$imagen" -thumbnail 500x500^ -gravity center -extent 500x500 "${cache_dir}/${filename}"
			fi
    fi
done


wall_selection=$(ls "${wall_dir}" -t | while read -r A ; do  echo -en "$A\0icon\x1f""${cache_dir}"/"$A\n" ; done | $rofi_command)
# Select a picture with rofi
#wall_selection=$(find "${wall_dir}"  -maxdepth 1  -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A ; do  echo -en "$A\x00icon\x1f""${cache_dir}"/"$A\n" ; done | $rofi_command)

# Set the wallpaper
[[ -n "$wall_selection" ]] || exit 1
swww img ${wall_dir}/${wall_selection}

if [[ "$wall_selection" == "result.png" ]]; then
    bash /home/ptmi/.config/niri/niri_theme_peach.sh
fi

if [[ "$wall_selection" == "hegyoldal.jpg" ]]; then
    bash /home/ptmi/.config/niri/niri_theme_green.sh
fi

if [[ "$wall_selection" == "pink_bike.jpg" ]]; then
    bash /home/ptmi/.config/niri/niri_theme_pink.sh
fi

if [[ "$wall_selection" == "evening-sky.png" ]]; then
    bash /home/ptmi/.config/niri/niri_theme_red.sh
fi

if [[ "$wall_selection" == "blue.jpg" ]]; then
    bash /home/ptmi/.config/niri/niri_theme_blue.sh
fi

exit 0


