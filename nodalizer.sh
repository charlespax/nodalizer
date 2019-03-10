#!/bin/bash

LODEKEY_VERSION="2019.03.04"
# Tested on lubuntu 18.10
# # Connect to wifi
# # git is already installed
# git clone https://github.com/charlespax/dotfiles
# cd dotfiles/scripts/
# ./bitcoin_setup.sh
# This installation process is taken from
# https://github.com/lightningnetwork/lnd/blob/master/docs/INSTALL.md

source ~/.bashrc

# TODO Check the operating system. The Bitcoin repository does not have packages for i386 CPUs
# for some realeases.
# TODO Support ARM 32-bit and 64-bit
# TODO Figure out a mechanism to updating the PATH in the bash session
#      from which the bitcoin script is run.
# TODO Keep a set of variables to store the status of each installation
# TODO Print a status report at the end of the script
# TODO Install via binary file
# TODO Give user configuration options (e.g. bitcoind or btcd?)

# Set architecture-independent variables
LND_VERSION_STRING="0.5.2-99-beta"
BITCOIN_CORE_VERSION="0.17.1"
# Set architecture-dependent variables
if [ "$(uname -p)" = "x86_64" ]; then
    GO_FILENAME="go1.11.5.linux-amd64.tar.gz"
    GO_HASH=`echo "ff54aafedff961eb94792487e827515da683d61a5f9482f668008832631e5d25"`
    GO_URL="https://dl.google.com/go/"
    GO_FILEURL=$GO_URL/$GO_FILENAME
    GO_VERSION_STRING="go version go1.11.5 linux/amd64"
    BITCOIN_CORE_FILENAME="bitcoin-$BITCOIN_CORE_VERSION-x86_64-linux-gnu.tar.gz"
    BITCOIN_CORE_FILE_URL="https://bitcoin.org/bin/bitcoin-core-$BITCOIN_CORE_VERSION/$BITCOIN_CORE_FILENAME"
    BITCOIN_CORE_HASH=`echo "53ffca45809127c9ba33ce0080558634101ec49de5224b2998c489b6d0fc2b17"`
elif [ "$(uname -p)" = "i686" ]; then
    GO_FILENAME="go1.11.5.linux-386.tar.gz"
    GO_HASH=`echo "acd8e05f8d3eed406e09bb58eab89de3f0a139d4aef15f74adeed2d2c24cb440"`
    GO_URL="https://dl.google.com/go/"
    GO_FILEURL=$GO_URL/$GO_FILENAME
    GO_VERSION_STRING="go version go1.11.5 linux/386"
    BITCOIN_CORE_FILENAME="bitcoin-$BITCOIN_CORE_VERSION-i686-pc-linux-gnu.tar.gz"
    BITCOIN_CORE_FILE_URL="https://bitcoin.org/bin/bitcoin-core-$BITCOIN_CORE_VERSION/$BITCOIN_CORE_FILENAME"
    BITCOIN_CORE_HASH=`echo "b1e1dcf8265521fef9021a9d49d8661833e3f844ca9a410a9dd12a617553dda1"`
else
    echo "Arch is $(uname -p)"
    # BITCOIN_CORE_FILE_URL="https://bitcoin.org/bin/bitcoin-core-$BITCOIN_CORE_VERSION/bitcoin-$BITCOIN_CORE_VERSION-aarch64-linux-gnu.tar.gz"
    # BITCOIN_CORE_HASH=`echo "5659c436ca92eed8ef42d5b2d162ff6283feba220748f9a373a5a53968975e34`"
    # BITCOIN_CORE_FILE_URL="https://bitcoin.org/bin/bitcoin-core-$BITCOIN_CORE_VERSION/bitcoin-$BITCOIN_CORE_VERSION-arm-linux-gnueabihf.tar.gz"
    # BITCOIN_CORE_HASH=`echo "aab3c1fb92e47734fadded1d3f9ccf0ac5a59e3cdc28c43a52fcab9f0cb395bc`"
fi

bitcoind_installed () {
    # return "true" if bitcoind is installed
    # return "false" otherwise
    local status="$(command -v bitcoind)"
    if [ "${status##*/}" = "bitcoind" ]; then
        echo "true"
    else
        echo "false"
    fi
}

install_bitcoind_from_ppa () {
    # Attempt to install bitcoind
    sudo apt-add-repository -y ppa:bitcoin/bitcoin
    sudo apt-get update
    sudo apt-get -y install bitcoind bitcoin-qt
    local status="$(command -v bitcoind)"
    if [ "${status##*/}" = "bitcoind" ]; then
        echo "Installing bitcoind from ppa... SUCCESS"
    else
        echo "Installing bitcoind from ppa... ERROR"
    fi
}

# TODO Add the package requirements to a variable at the top of the script
# then install all the requirements at the same time for all components
# TODO For each required package, verify it is installed
# TODO Make the directory paths relative to the user home directory
install_lightningd_from_source () {
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    cd $DIR
    pwd
#     sudo apt-get update
#     sudo apt-get install -y \
#         autoconf automake build-essential git libtool libgmp-dev \
#         libsqlite3-dev python python3 net-tools zlib1g-dev libsodium-dev \
#         asciidoc valgrind python3-pip
    echo "Cloning lightningd... "
    git clone https://github.com/ElementsProject/lightning.git
    cd lightning
    sudo pip3 install -r tests/requirements.txt
    #./configure
    #make
}
# TODO Use the official binaries for installation instead of repositories.
# Include a hash check. Note that the ppa does not have file for ubuntu
# disco prerelease as of 2019-02-26. In this case, using the official
# binaries would be better.
install_bitcoind_from_binary () {
    printf "Downloading Bitcoin Core... "
    wget -qc --show-progress $BITCOIN_CORE_FILE_URL 
    HASH="`sha256sum $BITCOIN_CORE_FILENAME | awk -F \" \" '{ print $1 }'`"
    echo "COMPLETE"
    printf "Verifying Bitcoin Core sha256... " 
    if [ "$HASH" = "$BITCOIN_CORE_HASH" ]; then
        echo "PASSED"
    else
        echo "ERROR: incorrect sha256 hash"
        exit 1
    fi
    echo "Installing bitcoin-$BITCOIN_CORE_VERSION... "
    tar xzf $BITCOIN_CORE_FILENAME
    sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-$BITCOIN_CORE_VERSION/bin/*
    if [ "$(bitcoind_installed)" = "true" ]; then
        echo "INSTALLED"
    else
        echo "Some kind of error"
    fi
}

go_installed () {
    # return "true" if 'go' is installed at or above desired version
    # return "false" otherwise
    if [ "$GO_VERSION_STRING" = "`command go version`" ]; then
        echo "true"
    else
        echo "false"
    fi
}

download_go() {
    # Download go
    # See https://golang.org/dl/ for the latest version of go
    # TODO Test to see if GO v1.11 or higher is installed before downloading
    # TODO Test to see golang 1.11 or higher is in the repositories
    #      v1.11 and 1.12 are in ubuntu-19.04 as of 2019-02-26
    # TODO Give the option of downloading from the repository or official binaries
    echo Downloading GO... 
    wget -qc --show-progress $GO_FILEURL 
    HASH="`sha256sum $GO_FILENAME | awk -F \" \" '{ print $1 }'`"
    echo Downloading GO... COMPLETE
    printf "Verifying GO sha256... " 
    if [ "$HASH" = "$GO_HASH" ]; then
        echo "PASSED"
    else
        echo "ERROR: incorrect sha256 hash"
        exit 1
    fi
}

install_go () {
    # Install GO
    printf "Checking GO installation... "
    DESIRED_GO_VERSION=$GO_VERSION_STRING
    if [ "$DESIRED_GO_VERSION" = "`command go version`" ]; then
        echo "$DESIRED_GO_VERSION installed"
    else
        # See if we already have the file
        if [ -f $GO_FILENAME ]; then
            echo "$GO_FILENAME found"
        else
            download_go
        fi
        printf "Installing GO language... "
        sudo tar -C /usr/local -xzf $GO_FILENAME
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=~/gocode
        export PATH=$PATH:$GOPATH/bin

        # TODO check if the environmental variables are set in bashrc
        # before adding this information again.
        echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
        echo "export GOPATH=~/gocode" >> ~/.bashrc
        echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.bashrc
        source ~/.bashrc
        if [ "$DESIRED_GO_VERSION" = "`command go version`" ]; then
            echo "COMPLETE"
            echo "Installing GO language... $DESIRED_GO_VERSION installed"
        else
            echo "Installing GO language... ERROR: 'go' not present"
            exit 1
        fi
    fi
}

install_lnd () {
    # Install lnd
    go get -d github.com/lightningnetwork/lnd
    cd $GOPATH/src/github.com/lightningnetwork/lnd
    make && make install
}

update_lnd () {
    cd $GOPATH/src/github.com/lightningnetwork/lnd
    if [ "$(git pull | tail -n 1)" = "Already up to date." ]; then
        echo "Already up to date."
    else
        make clean && make && make install
    fi
}

check_lnd () {
    cd $GOPATH/src/github.com/lightningnetwork/lnd
    make check
}

lnd_installed () {
    # TODO Make the version string check better. Just make sure the check
    # returns a version number and not an error.
    # return "true" if 'lnd' is installed at or above desired version
    # return "false" otherwise
    if [ "$(echo $LND_VERSION_STRING | cut -d ' ' -f 3)" = "$(command lnd --version | cut -d ' ' -f 3)" ]; then
        echo "true"
    else
        echo "false"
    fi
}

install_btcd () {
    # btcd is required for lnd to pass all unit tests. Having btcd installed
    # does not prevent bitcoind from being used.
    cd $GOPATH/src/github.com/lightningnetwork/lnd
    make btcd
}

install_btcctl () {
    cd $GOPATH/src/github.com/btcsuite/btcd
    GO111MODULE=on go install -v . ./cmd/...
}

BTCCTL_VERSION="0.12.0-beta"
btcctl_installed () {
    if [ "$BTCCTL_VERSION" = "$(command btcctl --version | cut -d ' ' -f 3)" ]; then
        echo "true"
    else
        echo "false"
    fi
}
print_welcome () {
    # TODO DO not print welcome screen if -q argument is given
    echo ""
    echo "███╗   ██╗ ██████╗ ██████╗  █████╗ ██╗     ██╗███████╗███████╗██████╗ ";
    echo "████╗  ██║██╔═══██╗██╔══██╗██╔══██╗██║     ██║╚══███╔╝██╔════╝██╔══██╗";
    echo "██╔██╗ ██║██║   ██║██║  ██║███████║██║     ██║  ███╔╝ █████╗  ██████╔╝";
    echo "██║╚██╗██║██║   ██║██║  ██║██╔══██║██║     ██║ ███╔╝  ██╔══╝  ██╔══██╗";
    echo "██║ ╚████║╚██████╔╝██████╔╝██║  ██║███████╗██║███████╗███████╗██║  ██║";
    echo "╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝";
    echo "                                                                      "
    echo "Bitcoin Lightning node helper        version $LODEKEY_VERSION"
    echo "  by Pax-o-tron"
    echo ""
    # Created with http://patorjk.com/software/taag/#p=display&h=0&v=0&f=ANSI%20Shadow&t=LodeKey
}

print_welcome

read -p "Continue? (Y/n): ";
if [ "$REPLY" = "n" ]; then
    exit
else
    true
fi

printf "Checking for bitcoind installation... "
if [ "$(bitcoind_installed)" = "true" ]; then
    echo "INSTALLED"
else
    echo "NOT installed"
    echo "Installing bitcoind from binary... "
    install_bitcoind_from_binary
    # echo "Installing bitcoind from ppa... "
    # install_bitcoind_from_ppa
fi

printf "Checking for go installation... "
if [ "$(go_installed)" = "true" ]; then
    echo "INSTALLED"
else
    echo "NOT installed"
    echo "Installing bitcoind from $GO_FILEURL "
    install_go
fi

printf "Checking for lnd installation... "
if [ "$(lnd_installed)" = "true" ]; then
    echo "INSTALLED"
    printf "Updating lnd... "
    update_lnd
else
    echo "NOT INSTALLED"
    echo "Installing lnd... "
    echo "This may take several minutes"
    # TODO Make install_lnd output information to the terminal
    install_lnd
    update_lnd
#    check_lnd
fi

printf "Checking btcd installation... "
if [ "$(command btcd --version)" = "btcd version 0.12.0-beta" ]; then
    echo "INSTALLED"
else
    install_btcd
fi

printf "Checking btcctl installation... "
if [ "$(btcctl_installed)" = "true" ]; then
    echo "INSTALLED"
else
    install_btcctl
fi

LIGHTNINGD_VERSION=""
printf "Checking lightningd installation... "
if [ "$LIGHTNINGD_VERSION" = "btcd version 0.12.0-beta" ]; then
    echo "INSTALLED"
else
    true
#    install_lightningd_from_source
fi
echo "Installation complete. Run 'source ~/.bashrc' to update this terminal session."

