#!/bin/bash

COSMOVISOR=$1
GIT_NAME=$2
GIT_FOLDER=$3
BIN_NAME=$4
BIN_VER=$5

if [ "$COSMOVISOR" == "" ]; then
    exit
fi

if [ "$GIT_NAME" == "" ]; then
    exit
fi

if [ "$GIT_FOLDER" == "" ]; then
    exit
fi

if [ "$BIN_NAME" == "" ]; then
    exit
fi

if [ "$BIN_VER" == "" ]; then
    exit
fi

function configuring {

mkdir -p $GOBIN ${HOME}/.${BIN_NAME}/cosmovisor/genesis/bin ${HOME}/.${BIN_NAME}/cosmovisor/upgrades/Gir/bin

mkdir -p $GOPATH/src/github.com/cosmos && cd $GOPATH/src/github.com/cosmos && git clone https://github.com/cosmos/cosmos-sdk && cd cosmos-sdk/cosmovisor && git checkout ${COSMOVISOR} && make cosmovisor

mv cosmovisor $GOBIN

echo "---------------"
echo "Cosmovisor built and installed."
echo "---------------"

mkdir $GOPATH/src/github.com/${GIT_FOLDER} && cd $GOPATH/src/github.com/${GIT_FOLDER} && git clone https://github.com/${GIT_NAME}/${GIT_FOLDER} && cd ${GIT_FOLDER} && git fetch && git checkout tags/${BIN_VER} && make install && make build

echo "---------------"
echo "${BIN_NAME} built and installed."
echo "---------------"

if [ -e $GOPATH/src/github.com/${GIT_FOLDER}/${GIT_FOLDER}/build/${BIN_NAME} ]; then
  cp build/${BIN_NAME} ${HOME}/.${BIN_NAME}/cosmovisor/genesis/bin
  cp build/${BIN_NAME} ${HOME}/.${BIN_NAME}/cosmovisor/upgrades/Gir/bin
else
  cd
  cp $GOBIN/${BIN_NAME} ${HOME}/.${BIN_NAME}/cosmovisor/genesis/bin
  cp $GOBIN/${BIN_NAME} ${HOME}/.${BIN_NAME}/cosmovisor/upgrades/Gir/bin
fi

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
}

function initialising {

echo "---------------"
echo "cosmovisor.service installed."
echo "---------------"

echo "Enter your Moniker"
read -p "Moniker: " MONIKER
${BIN_NAME} init $MONIKER

echo "---------------"
echo "Your Moniker: ${MONIKER}, initialised."
echo "---------------"

echo "Enter link to Genesis file"
read -p "Genesis link: " GENESIS
curl $GENESIS > ~/.${BIN_NAME}/config/genesis.json

echo "Enter Seeds"
read -p "Seed: " SEED
sed -i.bak -E 's#^(seeds[[:space:]]+=[[:space:]]+).*$#\1"'$SEED'"#' ~/.${BIN_NAME}/config/config.toml

echo "Enter Peers"
read -p "Persistent_peers: " PEERS
sed -i.bak -E 's#^(persistent_peers[[:space:]]+=[[:space:]]+).*$#\1"'$PEERS'"#' ~/.${BIN_NAME}/config/config.toml

echo "Enter minimum-gas-prices"
read -p "minimum-gas-prices: " GAS_PRICE
sed -i.bak -E 's#^(minimum-gas-prices[[:space:]]+=[[:space:]]+).*$#\1"'$GAS_PRICE'"#' ~/.${BIN_NAME}/config/app.toml

echo "---------------"
echo "${BIN_NAME} Configured and waiting to start."
echo "---------------"

echo "---------------"
echo "---------------"
echo "Installation of golang, ${BIN_NAME}, and cosmovisor complete."

echo "sudo systemctl start cosmovisor.service"
echo "---------------"

echo "To the Earth!"
echo "---------------"

sleep 5

sudo systemctl start cosmovisor.service

journalctl -u cosmovisor.service -f

}

configuring
initialising