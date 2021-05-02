# Setup COSMOVISOR for all Cosmos projects


## 1. Install GOLANG.
If you need install another GO versin you can change it in `./go.sh -v 1.15.7`. Or you can install GO from [official website](https://golang.org/doc/install).
```
wget https://gist.githubusercontent.com/icohigh/87158d3b79f9cb94ef15ba48072e240e/raw/559308a871b1010a9634c690e29ad86878f611a8/go.sh \
&& chmod +x go.sh \
&& ./go.sh -v 1.15.7
```
Then Restart your terminal.

## 2. Run COSMOVISOR setup and build.
Enter Enviroments `COSMOVISOR_VER GIT_NAME GIT_FOLDER BIN_NAME BIN_VER` and run this script to setup and build.
```
wget https://raw.githubusercontent.com/icohigh/cosmovisor-setup/main/cosmovisor.sh \
&& chmod +x cosmovisor.sh \
&& ./cosmovisor.sh COSMOVISOR_VER GIT_NAME GIT_FOLDER BIN_NAME BIN_VER
```
### On the example of the Desmos project:
COSMOVISOR_VER = v0.42.4
GIT_NAME = desmos-labs
GIT_FOLDER = desmos
BIN_NAME = desmos
BIN_VER = v0.16.0

The run command should look like this:
```
wget https://raw.githubusercontent.com/icohigh/cosmovisor-setup/main/cosmovisor.sh \
&& chmod +x cosmovisor.sh \
&& ./cosmovisor.sh v0.42.4 desmos-labs desmos desmos v0.16.0
```

### DONE