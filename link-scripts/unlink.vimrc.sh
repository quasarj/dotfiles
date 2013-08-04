#!/usr/bin/bash

#ln -s $HOME/.dotfiles/submodules/vimrc $HOME/.vim
#ln -s $HOME/.dotfiles/submodules/vimrc/_vimrc $HOME/.vimrc

. ~/.dotfiles/link-scripts/common.sh

echo Removing links for vimrc

remove_link ~/.vim
remove_link ~/.vimrc
