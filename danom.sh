#!/bin/bash

curl -s https://raw.githubusercontent.com/zamzasalim/logo/main/asc.sh | bash
sleep 5

sudo apt update && sudo apt install -y wget curl tar screen


wget https://github.com/DanomSite/release/releases/download/v4/DanomV4.tar.gz
tar -xvzf DanomV4.tar.gz


cd Danom


curl -fsSL 'https://testnet.danom.site/install.sh' | bash


echo "Masukkan Alamat Ethereum :"
read WALLET_ADDRESS
echo "Masukkan Token HuggingFace:"
read POOL_LIST


echo "{\"wallet\": \"$WALLET_ADDRESS\", \"pool_list\": \"$POOL_LIST\"}" > wallet_config.json

echo "Konfigurasi wallet telah berhasil dibuat!"


screen -S danom -d -m ./danom

echo "Proses berjalan di dalam screen session 'danom'."
