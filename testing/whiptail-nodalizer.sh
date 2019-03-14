#!/bin/bash

# This file is to test a 'whiptail' interface to nodalizer.

do_on_exit () {
    # Execute this when the script exits
    printf "Removing downloaded file... "
    rm netboot.tar.gz
    echo COMPLETE
}

ctrl_c () {
    # Execute this when the user presses Ctrl-c
    echo "Exiting via Ctrl-c..."
}

trap ctrl_c 2
trap do_on_exit EXIT

dialog --title "Welcome to" --msgbox "My test program." 15 60

# Download a file
URL="http://ftp.nl.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz"
wget -c "$URL" 2>&1 |  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | dialog --title "Download Test" --gauge "Ubuntu..." 6 60 0
# When using 'dialog':
#   - The msgbox can be escaped via ESC or Ctrl-c.
#   - The downloader can be excaped via Ctrl-c, but not ESC.
#   - The 'dialog' downloader gets paused when ESC is held down.
# When using 'whiptail':
#   - The greeter can be escaped Ctrl-c.
#   - The downloader can not be escaped by anything.
#   - If you press Ctrl-c while downloading, the script will exit
#     via ctrl-c() after the download is complete.

# ** KEEP THIS **
# This code block will download the files and use a gauge. Keep this
# here and copy-and-paste it above to make modifications for testing.
# URL="http://ftp.nl.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz"
# wget -c "$URL" 2>&1 |  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' |  dialog --title "Download Test" --gauge "Ubuntu..." 6 60 0
