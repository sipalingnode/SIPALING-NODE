#!/bin/bash

curl -s https://data.zamzasalim.xyz/file/uploads/asclogo.sh | bash
sleep 5

echo "CYSIC NODE"
sleep 2

read -p "Submit Your ETH Address : " eth_address

# Validasi format alamat Ethereum (cek dasar)
if [[ ! "$eth_address" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
    echo "Format alamat Ethereum tidak valid. Pastikan alamat dimulai dengan 0x dan diikuti dengan 40 karakter heksadesimal."
    exit 1
fi


echo "Mengunduh dan menginstal skrip setup..."
curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh
bash ~/setup_linux.sh $eth_address


echo "Membuat layanan systemd untuk Cysic Verifier..."

sudo tee /etc/systemd/system/cysic.service > /dev/null << EOF
[Unit]
Description=Cysic Verifier Node
After=network-online.target

[Service]
User=$USER
ExecStart=/bin/bash -c 'cd \$HOME/cysic-verifier && bash start.sh'
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


echo "Memuat ulang daemon systemd dan mengaktifkan layanan Cysic..."
sudo systemctl daemon-reload
sudo systemctl enable cysic
sudo systemctl start cysic

echo "Setup selesai. Node Cysic Verifier sekarang sedang berjalan."
