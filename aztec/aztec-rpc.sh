#!/bin/bash

curl -s https://raw.githubusercontent.com/zamzasalim/logo/main/asc.sh | bash
sleep 5

echo "CHANGE RPC AZTEC"
sleep 1

echo "Menghentikan node lama di tmux..."
tmux kill-session -t aztec
sleep 2
# Prompt pengguna untuk input penting
read -p "Masukkan ETH Sepolia RPC URL: " RPC_URL
read -p "Masukkan ETH Beacon (Consensus) RPC URL: " BEACON_URL
read -p "Masukkan Private Key Sequencer (0x...): " VALIDATOR_PRIVATE_KEY
read -p "Masukkan Alamat Sequencer (0x...): " COINBASE_ADDRESS
read -p "Masukkan IP VPS: " P2P_IP

# Validasi input: semua harus diisi
if [[ -z "$RPC_URL" || -z "$BEACON_URL" || -z "$VALIDATOR_PRIVATE_KEY" || -z "$COINBASE_ADDRESS" || -z "$P2P_IP" ]]; then
  echo "❌ Error: Semua input wajib diisi."
  exit 1
fi

# Bangun perintah node
NODE_COMMAND="aztec start --node --archiver --sequencer --network alpha-testnet \
--l1-rpc-urls \"$RPC_URL\" \
--l1-consensus-host-urls \"$BEACON_URL\" \
--sequencer.validatorPrivateKey \"$VALIDATOR_PRIVATE_KEY\" \
--sequencer.coinbase \"$COINBASE_ADDRESS\" \
--p2p.p2pIp \"$P2P_IP\" \
--p2p.maxTxPoolSize 1000000000"

# Jalankan di tmux
echo "Menjalankan node dengan RPC baru..."
tmux send-keys -t aztec "$NODE_COMMAND" C-m

# Info akhir
echo ""
echo "Node berhasil dijalankan ulang di tmux session 'aztec'."
echo "Untuk melihat log: tmux attach -t aztec"
echo "Untuk keluar dari tmux: Ctrl+b lalu tekan d"
