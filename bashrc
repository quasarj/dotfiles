# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


# powerline - this is pretty slow, but very pretty. Maybe do something else?
. ~/.local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh


yil () { # "yum install last"
    # This will call yi (yum install) on the last ys (yum search) command.
    # 
    # Explanation:
    # history: get the last two history items (the last one is this command)
    # head: take the first line of that output
    # cut: remove the first 8 characters (the history line number)
    # sed: replace the first occurence of "ys" with "sudo yum install"

    command=$(history 2 | head -n 1 | cut -c 8- | sed 's/ys/sudo yum install/')
    echo "Installing last yum search: $command"
    $command
}



# use vi mode
set -o vi

# load svn-color for pretty svn!
# . ~/bin/svn-color/svn-color.sh
# ensure it will work through less
export SVN_COLOR=always

# User specific aliases and functions
alias vi=gvim
alias vim=gvim
alias ll="ls -lh"
alias less="less -R" # always display colors
alias s=sudo
alias open=xdg-open
alias start=xdg-open
alias yi="sudo yum install"
alias ys="yum search"



# location variables

export rclua=$HOME/.config/awesome/rc.lua

export SVN_EDITOR=gvim

export JAVA_HOME=/opt/jdk1.6.0_45
export ORACLE_HOME=/usr/lib/oracle/11.2/client64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib

# paths
DOTFILESBIN=~/.dotfiles/bin
DOTFILESBINS=~/.dotfiles/system-specific-bin
MPLAYER_PATH=/opt/mplayer2/bin

LOCALPATH=$DOTFILESBIN:$DOTFILESBINS:$MPLAYER_PATH


export PATH=$LOCALPATH:$JAVA_HOME/bin:$ORACLE_HOME/bin:$PATH



