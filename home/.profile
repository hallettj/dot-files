# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

export ANSIBLE_ASK_SUDO_PASS=True

# That's right
export EDITOR=nvim
# And again
export VISUAL=$EDITOR

# Source configurations from ~/.config/profile.d/*
CONFIGS="$HOME/.config/profile.d"
if [ -d "$CONFIGS" ]; then
    for CONFIGFILE in "$CONFIGS"/*; do
        if [ -r "$CONFIGFILE" ]; then
            source "$CONFIGFILE"
        fi
    done
fi
