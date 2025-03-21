#!/bin/bash

curl -s https://raw.githubusercontent.com/zamzasalim/logo/main/asc.sh | bash
sleep 5
# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if curl is installed
if ! command_exists curl; then
    echo "curl is not installed. Installing..."
    sudo apt-get install -y curl
else
    echo "curl is already installed."
fi

# Check if clang is installed
if ! command_exists clang; then
    echo "clang is not installed. Installing..."
    sudo apt-get install -y clang
else
    echo "clang is already installed."
fi

# Check if cmake is installed
if ! command_exists cmake; then
    echo "cmake is not installed. Installing..."
    sudo apt-get install -y cmake
else
    echo "cmake is already installed."
fi

# Check if build-essential is installed
if ! dpkg -l | grep -q build-essential; then
    echo "build-essential is not installed. Installing..."
    sudo apt-get install -y build-essential
else
    echo "build-essential is already installed."
fi

# Check if pkg-config is installed
if ! command_exists pkg-config; then
    echo "pkg-config is not installed. Installing..."
    sudo apt-get install -y pkg-config
else
    echo "pkg-config is already installed."
fi

# Check if libssl-dev is installed
if ! dpkg -l | grep -q libssl-dev; then
    echo "libssl-dev is not installed. Installing..."
    sudo apt-get install -y libssl-dev
else
    echo "libssl-dev is already installed."
fi

# Check if protobuf-compiler is installed
if ! command_exists protoc; then
    echo "protobuf-compiler is not installed. Installing..."
    sudo apt-get install -y protobuf-compiler
else
    echo "protobuf-compiler is already installed."
fi

# Check if llvm is installed
if ! command_exists llvm; then
    echo "llvm is not installed. Installing..."
    sudo apt-get install -y llvm
else
    echo "llvm is already installed."
fi

# Check if llvm-dev is installed
if ! dpkg -l | grep -q llvm-dev; then
    echo "llvm-dev is not installed. Installing..."
    sudo apt-get install -y llvm-dev
else
    echo "llvm-dev is already installed."
fi

# Check if Go is installed
if ! command_exists go; then
    echo "Go is not installed. Installing..."
    ver="1.22.0"
    wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
    rm "go$ver.linux-amd64.tar.gz"
    echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bash_profile
    source ~/.bash_profile
else
    echo "Go is already installed."
    go version
fi

# Check if Rust is installed
if ! command_exists rustc; then
    echo "Rust is not installed. Installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
else
    echo "Rust is already installed."
    rustc --version
fi

# Check if git is installed
if ! command_exists git; then
    echo "git is not installed. Installing..."
    sudo apt-get install -y git
else
    echo "git is already installed."
fi

# Proceed with the rest of the script
rm -rf $HOME/0g-da-node
git clone https://github.com/0glabs/0g-da-node.git
cd 0g-da-node
git fetch --all --tags
git checkout v1.1.3
git submodule update --init
cargo build --release

./dev_support/download_params.sh

signer_bls_private_key=$(cargo run --bin key-gen | tail -n 1)
echo "Signer BLS Private Key: $signer_bls_private_key"

vps_ip=$(curl -s ifconfig.me)

echo "Enter other private keys"
read -p "Enter signer_eth_private_key: " signer_eth_private_key
read -p "Enter miner_eth_private_key: " miner_eth_private_key

cat > $HOME/0g-da-node/config.toml <<EOF
log_level = "info"
data_path = "./db/"
encoder_params_dir = "params/"
grpc_listen_address = "0.0.0.0:34000"
eth_rpc_endpoint = "https://evmrpc-testnet.0g.ai"
socket_address = "${vps_ip}:34000"
da_entrance_address = "0x857C0A28A8634614BB2C96039Cf4a20AFF709Aa9"
start_block_number = 940000
signer_bls_private_key = "${signer_bls_private_key}"
signer_eth_private_key = "${signer_eth_private_key}"
miner_eth_private_key = "${miner_eth_private_key}"
enable_das = "true"
EOF

# Create the systemd service file with the new name `0gda-node`
sudo tee /etc/systemd/system/0gda-node.service > /dev/null <<EOF
[Unit]
Description=0G-DA Node
After=network.target

[Service]
User=root
Environment="RUST_BACKTRACE=full"
Environment="RUST_LOG=debug"
WorkingDirectory=$HOME/0g-da-node
ExecStart=$HOME/0g-da-node/target/release/server --config $HOME/0g-da-node/config.toml
Restart=always
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service with the new name
sudo systemctl daemon-reload
sudo systemctl enable 0gda-node
sudo systemctl start 0gda-node

echo "Done. Cek Logs Gunakan 'sudo journalctl -u 0gda-node -f -o cat'"
