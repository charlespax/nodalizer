#!/bin/bash

# This file is to test a 'whiptail' interface to nodalizer.

NODALIZER_VERSION="0.1"
DATE="2019-03-05"


whiptail --title "Welcome to" --msgbox "\
 _   _           _       _ _\n\
| \ | | ___   __| | __ _| (_)_______ _ __\n\
|  \| |/ _ \ / _\` |/ _\` | | |_  / _ \ '__|\n\
| |\  | (_) | (_| | (_| | | |/ /  __/ |\n\
|_| \_|\___/ \__,_|\__,_|_|_/___\___|_|\n\
                            version $NODALIZER_VERSION\n \
A tool for creating a Bitcoin Lightning Node.\n \
By Charles pax"\
    15 60

