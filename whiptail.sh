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

NODALIZER_VERSION="0.1"

dialog --title "Welcome to" --msgbox "\
 _   _           _       _ _\n\
| \ | | ___   __| | __ _| (_)_______ _ __\n\
|  \| |/ _ \ / _\` |/ _\` | | |_  / _ \ '__|\n\
| |\  | (_) | (_| | (_| | | |/ /  __/ |\n\
|_| \_|\___/ \__,_|\__,_|_|_/___\___|_|\n\
                            version $NODALIZER_VERSION\n \
A tool for creating a Bitcoin Lightning Node.\n \
By Charles pax"\
    15 60

# Download a file
# When using 'dialog' the greeter can be escaped via ESC or Ctrl-c. The downloader can be excaped via Ctrl-c, but not ESC.
# When using 'whiptail' the greeter can be escaped via ESC or Ctrl-c. The download can not be excaped by anything. However,
# if you press Ctrl-c while downloading, the script will exit via ctrl-c() after the download is complete.
# Also of note; the 'dialog' downloader gets paused when ESC is held down.
URL="http://ftp.nl.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz"
wget -c "$URL" 2>&1 |  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | dialog --title "Download Test" --gauge "Ubuntu..." 6 60 0

# This code block will download the files and use a gauge. Keep this
# here and copy it above to make modification for testing.
# URL="http://ftp.nl.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz"
# wget -c "$URL" 2>&1 |  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' |  dialog --title "Download Test" --gauge "Ubuntu..." 6 60 0
