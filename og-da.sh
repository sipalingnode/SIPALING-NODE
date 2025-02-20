#!/bin/bash

curl -s https://data.zamzasalim.xyz/file/uploads/asclogo.sh | bash
sleep 5

sudo apt update && sudo apt upgrade -y

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

    
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker is already installed, skipping installation."
fi

sudo apt install git -y


git clone https://github.com/0glabs/0g-da-client.git


cd 0g-da-client || exit
docker build -t 0g-da-client -f combined.Dockerfile .


read -p "Submit private key metamask: " PRIVATE_KEY

# Remove '0x' from private key if it exists
PRIVATE_KEY=${PRIVATE_KEY#0x}

# Validate private key format
if [[ ! $PRIVATE_KEY =~ ^[a-fA-F0-9]{64}$ ]]; then
    echo "ERROR: Invalid private key format. Please enter a valid 64-character hex key."
    exit 1
fi

# Generate ogda.env with the provided private key
cat <<EOF > ogda.env
COMBINED_SERVER_CHAIN_RPC=https://evmrpc-testnet.0g.ai
COMBINED_SERVER_PRIVATE_KEY=$PRIVATE_KEY
ENTRANCE_CONTRACT_ADDR=0x857C0A28A8634614BB2C96039Cf4a20AFF709Aa9
COMBINED_SERVER_RECEIPT_POLLING_ROUNDS=180
COMBINED_SERVER_RECEIPT_POLLING_INTERVAL=1s
COMBINED_SERVER_TX_GAS_LIMIT=2000000
COMBINED_SERVER_USE_MEMORY_DB=true
COMBINED_SERVER_KV_DB_PATH=/runtime/
COMBINED_SERVER_TimeToExpire=2592000
DISPERSER_SERVER_GRPC_PORT=51001
BATCHER_DASIGNERS_CONTRACT_ADDRESS=0x0000000000000000000000000000000000001000
BATCHER_FINALIZER_INTERVAL=20s
BATCHER_CONFIRMER_NUM=3
BATCHER_MAX_NUM_RETRIES_PER_BLOB=3
BATCHER_FINALIZED_BLOCK_COUNT=50
BATCHER_BATCH_SIZE_LIMIT=500
BATCHER_ENCODING_INTERVAL=3s
BATCHER_ENCODING_REQUEST_QUEUE_SIZE=1
BATCHER_PULL_INTERVAL=10s
BATCHER_SIGNING_INTERVAL=3s
BATCHER_SIGNED_PULL_INTERVAL=20s
BATCHER_EXPIRATION_POLL_INTERVAL=3600
BATCHER_ENCODER_ADDRESS=DA_ENCODER_SERVER
BATCHER_ENCODING_TIMEOUT=300s
BATCHER_SIGNING_TIMEOUT=60s
BATCHER_CHAIN_READ_TIMEOUT=12s
BATCHER_CHAIN_WRITE_TIMEOUT=13s
EOF

echo "RUNNING-NODE"
docker run -d --env-file ogda.env --name 0g-da-client -v ./run:/runtime -p 51001:51001 0g-da-client combined

echo "DONE......."
