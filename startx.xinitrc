# Sample configuration file for running Xfce Desktop from /usr/local
#
# First, make a backup of your current ~/.xinitrc if necessary.
# Rename this file to ~/.xinitrc and use 'startx' from a tty.
# You may prefer not run that with your normal user account.
# You should use a TEST account (e.g. create a 'xfce' user).
# If your are logged in a X Session, switch to tty2 and run 'startx -- :1'

export XDG_CONFIG_DIRS=/usr/local/etc/xdg:/etc/xdg
export XDG_DATA_DIRS=/usr/local/share:/usr/share:$XDG_DATA_DIRS
export DESKTOP_SESSION=xfce4
export GTK_DATA_PREFIX=/usr/local
export EDITOR=vim
export LD_LIBRARY_PATH=/usr/local/lib
exec dbus-launch xfce4-session

