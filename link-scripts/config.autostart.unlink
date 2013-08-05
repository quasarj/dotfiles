#!/usr/bin/bash

. ~/.dotfiles/link-scripts/common.sh


for file in $DOTFILES/config/autostart/*.desktop; do
    remove_link ~/.config/autostart/$(basename $file)
done

