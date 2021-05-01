#!/bin/bash

COSMOVISOR=$1
GIT_PATH=$2
BIN_NAME=$3
BIN_VER=$4

if [ "$COSMOVISOR" == "" ]; then
    exit
fi

if [ "$GIT_PATH" == "" ]; then
    exit
fi

if [ "$BIN_NAME" == "" ]; then
    exit
fi

if [ "$BIN_VER" == "" ]; then
    exit
fi

mkdir -p $GOBIN ${HOME}/.${BIN_NAME}/cosmovisor/genesis/bin ${HOME}/.${BIN_NAME}/cosmovisor/upgrades/Gir/bin

mkdir -p $GOPATH/src/github.com/cosmos && cd $GOPATH/src/github.com/cosmos && git clone https://github.com/cosmos/cosmos-sdk && cd cosmos-sdk/cosmovisor && git checkout ${COSMOVISOR} && make cosmovisor

mv cosmovisor $GOBIN

echo "Cosmovisor built and installed."

mkdir $GOPATH/src/github.com/${BIN_NAME} && cd $GOPATH/src/github.com/${BIN_NAME} && git clone https://github.com/${GIT_PATH} && cd ${BIN_NAME} && git fetch && git checkout tags/${BIN_VER} && make build

echo "${BIN_NAME} built and installed."

mv build/${BIN_NAME} ${HOME}/.${BIN_NAME}/cosmovisor/genesis/bin

mv build/${BIN_NAME} ${HOME}/.${BIN_NAME}/cosmovisor/upgrades/Gir/bin

ln -s -T ${HOME}/.${BIN_NAME}/cosmovisor/upgrades/Gir ${HOME}/.${BIN_NAME}/cosmovisor/current

cd
echo "export PATH=/root/.${BIN_NAME}/cosmovisor/current/bin:\$PATH" >> ~/.profile
. ~/.profile

echo "[Unit]
Description=${BIN_NAME}
After=network-online.target
[Service]
User=${USER}
Environment=DAEMON_NAME=${BIN_NAME}
Environment=DAEMON_RESTART_AFTER_UPGRADE=true
Environment=DAEMON_HOME=${HOME}/.${BIN_NAME}
ExecStart=$(which cosmovisor) start
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" >/etc/systemd/system/cosmovisor.service

sudo systemctl daemon-reload && sudo systemctl enable cosmovisor.service

echo "---------------"
echo "---------------"
echo "Installation of golang, ${BIN_NAME}, and cosmovisor complete."

echo "sudo systemctl start cosmovisor.service"
echo "---------------"

echo "To the Earth!"
echo "---------------"
