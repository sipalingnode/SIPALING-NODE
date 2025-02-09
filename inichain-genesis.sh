#!/bin/bash

curl -s https://data.zamzasalim.xyz/file/uploads/asclogo.sh | bash
sleep 5

echo "INICHAIN NODE"
sleep 2

# Langkah 1: Minta pengguna untuk memasukkan wallet address dan worker name
echo "Submit Address ETH:"
read WALLET_ADDRESS

echo "Submit Nama Worker (bisa pake namamu):"
read WORKER_NAME

# Validasi input (Pastikan tidak kosong)
if [ -z "$WALLET_ADDRESS" ] || [ -z "$WORKER_NAME" ]; then
  echo "Alamat dompet atau nama worker tidak boleh kosong!"
  exit 1
fi

# Tentukan lokasi file miner
MINER_PATH="/usr/local/bin/iniminer-linux-x64"

# Langkah 2: Cek apakah IniChain Miner sudah terunduh
if [[ ! -f "$MINER_PATH" ]]; then
  echo "IniChain Miner belum terunduh. Mengunduh file..."
  # Unduh IniChain Miner
  wget -q https://github.com/Project-InitVerse/ini-miner/releases/download/v1.0.0/iniminer-linux-x64 -O "$MINER_PATH"

  # Pastikan file telah terunduh
  if [[ ! -f "$MINER_PATH" ]]; then
    echo "Gagal mengunduh IniChain Miner!"
    exit 1
  else
    echo "IniChain Miner berhasil diunduh."
  fi
else
  echo "IniChain Miner sudah ada, melanjutkan ke langkah berikutnya..."
fi

# Langkah 3: Memberikan izin eksekusi pada file miner
echo "Memberikan izin eksekusi pada file miner..."
chmod +x "$MINER_PATH"

# Langkah 4: Buat skrip eksekusi
echo "Membuat skrip untuk menjalankan miner..."
cat > /usr/local/bin/start-iniminer.sh <<EOL
#!/bin/bash
cd /usr/local/bin
./iniminer-linux-x64 --pool stratum+tcp://$WALLET_ADDRESS.$WORKER_NAME@pool-core-testnet.inichain.com:32672 --cpu-devices 1 --cpu-devices 2
EOL

# Memberikan izin eksekusi pada skrip
chmod +x /usr/local/bin/start-iniminer.sh

# Langkah 5: Membuat unit file systemd
echo "Membuat unit file systemd..."
cat > /etc/systemd/system/iniminer.service <<EOL
[Unit]
Description=IniChain Miner
After=network.target

[Service]
ExecStart=/usr/local/bin/start-iniminer.sh
WorkingDirectory=/usr/local/bin
User=$(whoami)
Restart=always
Nice=10
CPUShares=1024

[Install]
WantedBy=multi-user.target
EOL

# Langkah 6: Reload systemd dan enable layanan
echo "Melakukan reload systemd dan enable layanan..."
systemctl daemon-reload
systemctl enable iniminer.service
systemctl start iniminer.service

# Mengecek status layanan
echo "Mengecek status layanan IniChain Miner..."
systemctl status iniminer.service
