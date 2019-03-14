!/bin/bash

sudo apt-get install -y openssh-server vim git
git clone https://github.com/charlespax/nodalizer ~/nodalizer
cd ~/nodalizer

# Setup the VM for ssh
# connect via
# rule name: ssh
# host port: 3022
# guest port: 22
# ssh -p 3022 charles@127.0.1.1
