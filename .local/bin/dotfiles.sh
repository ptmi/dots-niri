#!/bin/bash

git init --bare $HOME/.dots


git --git-dir=$HOME/.dots config --local status.showUntrackedFiles no



git --git-dir=$HOME/.dots/ --work-tree=$HOME add /home/ptmi/.config/niri
git --git-dir=$HOME/.dots/ --work-tree=$HOME add /home/ptmi/.config/quickshell
git --git-dir=$HOME/.dots/ --work-tree=$HOME add /home/ptmi/.config/rofi
git --git-dir=$HOME/.dots/ --work-tree=$HOME add /home/ptmi/Pictures
git --git-dir=$HOME/.dots/ --work-tree=$HOME add /home/ptmi/.config/kitty
git --git-dir=$HOME/.dots/ --work-tree=$HOME add /home/ptmi/.config/fish
git --git-dir=$HOME/.dots/ --work-tree=$HOME add /home/ptmi/.local/bin

git --git-dir=$HOME/.dots/ --work-tree=$HOME commit -m 'Updates'


git --git-dir=$HOME/.dots/ --work-tree=$HOME push -f origin master
