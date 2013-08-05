#!/usr/bin/bash

. ~/.dotfiles/link-scripts/common.sh


for file in $DOTFILES/config/autostart/*.desktop; do
    add_link $file ~/.config/autostart/$(basename $file)
done

