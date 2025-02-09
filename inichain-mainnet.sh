#!/bin/bash

curl -s https://data.zamzasalim.xyz/file/uploads/asclogo.sh | bash
sleep 5

# Tentukan nama pengguna dan direktori instalasi
USER_NAME=$(whoami)
DOWNLOAD_DIR="/home/$USER_NAME/inchain-mainnet"  # Ganti nama folder ke inchain-mainnet
SERVICE_FILE="/etc/systemd/system/inchain-mainnet.service"  # Ganti nama layanan ke inchain-mainnet

# Tentukan URL perangkat lunak penambangan
URL="https://github.com/Project-InitVerse/ini-miner/releases/latest/download/iniminer-linux-x64"

# Membuat direktori untuk instalasi
echo "Membuat direktori instalasi di $DOWNLOAD_DIR..."
mkdir -p $DOWNLOAD_DIR

# Mengunduh perangkat lunak penambangan
cd $DOWNLOAD_DIR
echo "Mengunduh perangkat lunak penambangan..."
wget $URL -O iniminer-linux-x64
chmod +x iniminer-linux-x64

# Meminta input dari pengguna untuk alamat dompet dan nama pekerja
read -p "Masukkan alamat dompet Anda: " WALLET_ADDRESS
read -p "Masukkan nama pekerja (misal: Worker001): " WORKER_NAME

# Memilih kolam penambangan
echo "Pilih kolam penambangan utama:"
echo "1. Mainnet Pool a"
echo "2. Mainnet Pool b"
read -p "Pilih (1 atau 2): " POOL_CHOICE

if [ "$POOL_CHOICE" == "1" ]; then
  POOL_URL="stratum+tcp://$WALLET_ADDRESS.$WORKER_NAME@pool-a.yatespool.com:31588"
elif [ "$POOL_CHOICE" == "2" ]; then
  POOL_URL="stratum+tcp://$WALLET_ADDRESS.$WORKER_NAME@pool-b.yatespool.com:32488"
else
  echo "Pilihan tidak valid. Keluar."
  exit 1
fi

# Membuat file unit systemd
echo "Membuat file unit systemd untuk layanan penambangan..."
sudo bash -c "cat > $SERVICE_FILE <<EOF
[Unit]
Description=InChain Mainnet Mining Service  # Deskripsi layanan diperbarui
After=network.target

[Service]
ExecStart=/bin/bash $DOWNLOAD_DIR/start-mining.sh
WorkingDirectory=$DOWNLOAD_DIR
User=$USER_NAME
Group=$USER_NAME
Restart=always
RestartSec=5s
Environment=HOME=/home/$USER_NAME

[Install]
WantedBy=multi-user.target
EOF"

# Membuat skrip untuk memulai penambangan secara otomatis
echo "Membuat skrip start-mining.sh..."
cat > $DOWNLOAD_DIR/start-mining.sh <<EOF
#!/bin/bash

# Menjalankan penambangan
echo "Mulai penambangan..."
./iniminer-linux-x64 --pool $POOL_URL --cpu-devices 0
EOF

chmod +x $DOWNLOAD_DIR/start-mining.sh

# Menjalankan dan mengaktifkan layanan systemd
echo "Mengaktifkan dan memulai layanan penambangan..."
sudo systemctl daemon-reload
sudo systemctl enable inchain-mainnet.service  # Perbarui nama layanan ke inchain-mainnet
sudo systemctl start inchain-mainnet.service   # Perbarui nama layanan ke inchain-mainnet

# Menampilkan status layanan
echo "Layanan penambangan telah dimulai. Anda dapat memeriksa statusnya dengan perintah:"
echo "sudo systemctl status inchain-mainnet.service"  # Perbarui nama layanan ke inchain-mainnet
