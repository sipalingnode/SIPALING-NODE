#!/bin/bash

curl -s https://data.zamzasalim.xyz/file/uploads/asclogo.sh | bash
sleep 5

# Step 1: Cek apakah Docker sudah terinstal
if command -v docker &>/dev/null; then
    echo "Docker sudah terinstal. Melewati instalasi Docker."
else
    # Jika Docker belum terinstal, lakukan instalasi
    echo "Menginstal Docker..."
    sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Menambahkan GPG key Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 

    # Menambahkan repositori Docker
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Update indeks APT
    sudo apt update

    # Instal Docker
    sudo apt install -y docker-ce

    # Verifikasi instalasi Docker
    sudo docker --version

    # Menjalankan dan mengaktifkan layanan Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "Instalasi Docker selesai."
fi

if [ -d "/privasea" ]; then
    echo "Folder /privasea sudah ada. Menghapus folder..."
    sudo rm -rf /privasea
else
    echo "Folder /privasea tidak ditemukan."
fi

# Step 2: Memeriksa apakah folder $HOME/privasea sudah ada
if [ -d "$HOME/privasea" ]; then
    echo "Folder $HOME/privasea sudah ada. Menghapus folder..."
    sudo rm -rf $HOME/privasea
else
    echo "Folder $HOME/privasea tidak ditemukan."
fi

# Step 2a: Membuat direktori $HOME/privasea/config dan berpindah ke dalamnya
echo "Membuat folder $HOME/privasea/config dan masuk ke direktori $HOME/privasea..."
mkdir -p $HOME/privasea/config && cd $HOME/privasea

# Step 3: Cek apakah container privasea/acceleration-node-beta sudah ada (termasuk yang sudah berhenti)
echo "Memeriksa apakah container privasea/acceleration-node-beta sudah ada..."

# Mencari container dengan image privasea/acceleration-node-beta (termasuk yang sudah berhenti)
container_id=$(docker ps -a -q --filter "ancestor=privasea/acceleration-node-beta:latest")

if [ ! -z "$container_id" ]; then
    echo "Container dengan image privasea/acceleration-node-beta ditemukan. Menghentikan dan menghapus container..."
    sudo docker stop $container_id
    sudo docker rm $container_id
else
    echo "Tidak ada container dengan image privasea/acceleration-node-beta."
fi

# Step 4: Cek apakah gambar Docker sudah terunduh
echo "Memeriksa apakah gambar Docker privasea/acceleration-node-beta sudah terunduh..."
docker images | grep -q "privasea/acceleration-node-beta" || docker pull privasea/acceleration-node-beta:latest

# Langsung melanjutkan ke pembuatan keystore tanpa pemeriksaan
echo "Membuat keystore baru..."

# Menjalankan perintah untuk membuat keystore baru
docker run -it -v "$HOME/privasea/config:/app/config" privasea/acceleration-node-beta:latest ./node-calc new_keystore

# Step 6: Deteksi otomatis nama file keystore
keystore_file=$(ls $HOME/privasea/config | grep "UTC" | head -n 1)

sleep 3

# Step 7: Ganti nama file keystore menjadi wallet_keystore
mv $HOME/privasea/config/$keystore_file $HOME/privasea/config/wallet_keystore

# Langkah 8: Pilihan untuk melanjutkan atau tidak
read -p "Apakah Anda ingin melanjutkan untuk menjalankan node (y/n)? " choice
if [[ "$choice" != "y" ]]; then
    echo "Proses dibatalkan."
    exit 0
fi

# Langkah 9: Meminta password untuk keystore
echo "Masukkan password keystore"
read -s KEystorePassword
echo ""

# Langkah 10: Jalankan node
echo "Menjalankan Privasea Acceleration Node..."
if docker run -d -v "$HOME/privasea/config:/app/config" \
-e KEYSTORE_PASSWORD=$KEystorePassword \
--name acceleration-node \
privasea/acceleration-node-beta:latest; then
    echo "Node berhasil dijalankan.. Tunggu untuk merestart"
else
    echo "Gagal menjalankan node"
    exit 1
fi

sleep 5

# Step 11: Restart semua Docker container dengan image privasea/acceleration-node-beta:latest
echo "Merestart semua Docker container dengan image privasea/acceleration-node-beta:latest..."
docker ps -a -q --filter "ancestor=privasea/acceleration-node-beta:latest" | while read container_id; do
    echo "Merestart container dengan ID $container_id..."
    docker restart $container_id
done

echo "Instalasi Docker, konfigurasi node, dan pengaturan container selesai!"
