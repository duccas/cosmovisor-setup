#!/bin/bash

# This script sets up a node for the Aplikigo-1 Testnet of regen-ledger.
# One of the lines assumes that a ~/.regen/data backup from block 138651
# or later will be put in place before starting cosmovisor.
# Run this as a user that can sudo.
# You must run this script twice:
# once to install go, then reboot, then again to install regen-ledger and cosmovisor.

echo "If you want your go workspace in /home/dev/go-space,"
echo "give these answers when the script asks you:"
echo "Where would you like your Go Workspace folder to be? (example: /home)"
echo "Path: /home/dev"
echo "Give the folder a name: go-space"
echo "Press space to continue."
read -s -d ' '

cd ~
wget https://raw.githubusercontent.com/jim380/node_tooling/master/cosmos/scripts/go_install.sh
chmod +x go_install.sh
./go_install.sh -v 1.15.5
. ~/.profile
echo "export GOBIN=$GOPATH/bin" >> ~/.profile
. ~/.profile
go version
echo "PATH is:" $PATH
echo "GOPATH is:" $GOPATH
echo "GOBIN is:" $GOBIN
echo "Check the go version: if it's empty, please press Ctrl-c to exit,"
echo "and then reboot, and run this script again."
echo "Press space to continue."
read -s -d ' '

# mkdir -p $GOPATH/src/github.com/regen
# cd $GOPATH/src/github.com/regen
# git clone https://github.com/regen-network/regen-ledger.git && cd regen-ledger
# git checkout v0.6.1
# EXPERIMENTAL=true make install

# regen version --long

# echo "Check the regen version. Press space to continue."
# read -s -d ' '

mkdir -p $GOBIN ${HOME}/.regen/cosmovisor/genesis/bin ${HOME}/.regen/cosmovisor/upgrades/Gir/bin

mkdir -p $GOPATH/src/github.com/cosmos && cd $GOPATH/src/github.com/cosmos && git clone https://github.com/cosmos/cosmos-sdk && cd cosmos-sdk/cosmovisor && git checkout v0.41.0 && make cosmovisor

mv cosmovisor $GOBIN

echo "Cosmovisor built and installed. Press space to continue."
read -s -d ' '

mkdir $GOPATH/src/github.com/regen-network && cd $GOPATH/src/github.com/regen-network && git clone https://github.com/regen-network/regen-ledger && cd regen-ledger && git fetch && git checkout v0.6.0 && make build

mv build/regen ${HOME}/.regen/cosmovisor/genesis/bin

git checkout v0.6.1 && EXPERIMENTAL=true make build

./build/regen version

echo "Regen-ledger v0.6.0 and v0.6.1 built and installed. Press space to continue."
read -s -d ' '

mv build/regen ${HOME}/.regen/cosmovisor/upgrades/Gir/bin

# Use the first line if you're starting from before block 138650.
# ln -s -T ${HOME}/.regen/cosmovisor/genesis ${HOME}/.regen/cosmovisor/current
ln -s -T ${HOME}/.regen/cosmovisor/upgrades/Gir ${HOME}/.regen/cosmovisor/current

echo "export PATH=/home/$USER/.regen/cosmovisor/current/bin:\$PATH" >> ~/.profile
. /home/$USER/.profile


echo "[Unit]
Description=Regen Node
After=network-online.target
[Service]
User=${USER}
Environment=DAEMON_NAME=regen
Environment=DAEMON_RESTART_AFTER_UPGRADE=true
Environment=DAEMON_HOME=${HOME}/.regen
ExecStart=$(which cosmovisor) start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" >cosmovisor.service

sudo mv cosmovisor.service /lib/systemd/system/

sudo systemctl daemon-reload && sudo systemctl enable cosmovisor.service

echo "---------------"
echo "---------------"
echo "Installation of golang, regen-ledger, and cosmovisor complete."
echo "Now, to join the Aplikigo-1 Testnet, you can run"
echo "regen init --chain-id=aplikigo-1 <your_moniker>"
echo "and then"
echo "regen keys add <your-new-key> -i"
echo "Make sure you back up the mnemonics !!!"
echo "Or if you have the mnemonic for a key, you can import it with"
echo "regen keys add <key-name> --recover"
echo "---------------"

echo "To configure your node before starting, see"
echo "https://github.com/regen-network/testnets/tree/master/aplikigo-1#start-your-validator"
echo "---------------"

echo "Before starting your node, review the utility scripts at"
echo "https://github.com/swidnikk/regen-utils"
echo "---------------"


echo "If you want to make any changes to you config,"
echo "do that before starting cosmovisor,"
echo "otherwise you'll have to restart after making changes."
echo "---------------"

echo "If you run"
echo "which regen"
echo "and don't get a path, then run:"
echo ". /home/$USER/.profile"
echo "and then try \"which regen\" again."
echo "---------------"

echo "To fetch a data backup via scp, you might use"
echo "scp -v user@ip.address:/home/user/.regen/data-backup.tar.gz ."
echo "---------------"

echo "After your key is installed, and you have reviewed those scripts,"
echo "and you have put any backup data in ~/.regen/data,"
echo "you can start running your node with:"
echo "sudo systemctl start cosmovisor.service"
echo "---------------"

echo "To the Earth!"
echo "---------------"