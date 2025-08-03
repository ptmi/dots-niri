#!/bin/bash

wall_dir="$HOME/Pictures/Wallpapers"
thumb_dir="$HOME/.cache/wall-thumbs"

mkdir -p "$thumb_dir"

for img in ~/Pictures/Wallpapers/*.{jpg,jpeg,png,webp}; do
  [[ -f "$img" ]] || continue
  convert "$img" -resize 256x144^ -gravity center -extent 256x144 "$thumb_dir/$(basename "$img")"
done

# Create list of wallpapers
wall_selection=$(ls "$thumb_dir" | sort | tofi --prompt-text "󰉏 Pick wallpaper" --config ~/.config/tofi/wallpaper.tofi)

# Exit if nothing selected
[[ -z "$wall_selection" ]] && exit

# Set wallpaper
swww img "$wall_dir/$wall_selection"

# Trigger theme if applicable
script="$HOME/.config/niri/niri_theme_${wall_selection%.*}.sh"
[[ -x "$script" ]] && bash "$script"
