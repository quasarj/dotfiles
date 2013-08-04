#!/usr/bin/bash

DOTFILES=~/.dotfiles


add_link () {
    if [ -e $2 ]; then
        echo Link \(or file\) already exists, nothing to do. \
            Maybe delete it first?
        echo "    $2"
    else
        echo Adding link: $2
        ln -s $1 $2
    fi
}


remove_link () {
    if [ -L $1 ]; then
        echo Removing link: $1
        rm $1
    else
        echo Error: Not a link, so I won\'t remove it: $1
    fi
}
