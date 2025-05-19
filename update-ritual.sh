#!/bin/bash

curl -s https://raw.githubusercontent.com/zamzasalim/logo/main/asc.sh | bash
sleep 5

rm -rf ritual-service.sh
rm -rf ritual-deployment.log
rm -rf ritual-service.log
rm -rf infernet-container-starter

# === EARLY CLEANUP SECTION ===
echo ">> Stopping running containers and removing specific Docker images..."

if systemctl is-active --quiet ritual-network.service; then
  echo "Stopping ritual-network.service..."
  sudo systemctl stop ritual-network.service
fi

if systemctl is-enabled --quiet ritual-network.service; then
  echo "Disabling ritual-network.service..."
  sudo systemctl disable ritual-network.service
fi

SERVICE_FILE="/etc/systemd/system/ritual-network.service"
if [ -f "$SERVICE_FILE" ]; then
  echo "Removing $SERVICE_FILE..."
  sudo rm "$SERVICE_FILE"
fi

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

IMAGES_TO_REMOVE=(
  "ritualnetwork/infernet-node"
  "ritualnetwork/hello-world-infernet"
  "ritualnetwork/infernet-anvil"
  "fluent/fluent-bit"
  "redis"
)

for base_image in "${IMAGES_TO_REMOVE[@]}"; do
  image_ids=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "^$base_image:" | awk '{print $2}')
  
  for image_id in $image_ids; do
    container_ids=$(docker ps -q --filter "ancestor=$image_id")

    if [ -n "$container_ids" ]; then
      echo "Stopping and removing container(s) running image: $base_image"
      docker stop $container_ids
      docker rm $container_ids
    fi

    echo "Removing image: $image_id"
    docker rmi "$image_id"
  done
done

echo ">> Cleanup complete."

# === INSTALLATION AND SETUP SECTION ===

sudo ufw allow ssh
sudo ufw enable
sudo ufw status

if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Installing Docker..."
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo docker run hello-world
else
  echo "Docker is already installed."
fi

if ! command -v docker-compose &> /dev/null; then
  echo "Docker Compose is not installed. Installing Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
  mkdir -p $DOCKER_CONFIG/cli-plugins
  curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
  chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
  docker compose version
  sudo usermod -aG docker $USER
  docker run hello-world
else
  echo "Docker Compose is already installed."
fi

for pkg in git jq lz4 screen; do
  if ! command -v $pkg &> /dev/null; then
    echo "$pkg is not installed. Installing $pkg..."
    sudo apt install -y $pkg
  else
    echo "$pkg is already installed."
  fi
done

echo "Cloning repository..."
git clone https://github.com/ritual-net/infernet-container-starter
cd infernet-container-starter

echo "Updating infernet-node version to 1.4.0 in docker-compose.yaml..."
sed -i 's|\(ritualnetwork/infernet-node:\).*|\11.4.0|' deploy/docker-compose.yaml

# Input section
echo "Submit Privatekey Metamask"
read -s private_key
echo "Private key received (hidden for security)"

if [[ ! $private_key =~ ^0x ]]; then
  private_key="0x$private_key"
  echo "Added 0x prefix to private key"
fi

echo "Submit RPC BASE MAINNET"
read rpc_url
echo "RPC URL received: $rpc_url"

cat > ~/infernet-container-starter/deploy/config.json << EOL
{
    "log_path": "infernet_node.log",
    "server": {
        "port": 4000,
        "rate_limit": {
            "num_requests": 100,
            "period": 100
        }
    },
    "chain": {
        "enabled": true,
        "trail_head_blocks": 3,
        "rpc_url": "${rpc_url}",
        "registry_address": "0x3B1554f346DFe5c482Bb4BA31b880c1C18412170",
        "wallet": {
          "max_gas_limit": 4000000,
          "private_key": "${private_key}",
          "allowed_sim_errors": []
        },
        "snapshot_sync": {
          "sleep": 3,
          "batch_size": 1000,
          "starting_sub_id": 245000,
          "sync_period": 30
        }
    },
    "startup_wait": 1.0,
    "redis": {
        "host": "redis",
        "port": 6379
    },
    "forward_stats": true,
    "containers": [
        {
            "id": "hello-world",
            "image": "ritualnetwork/hello-world-infernet:latest",
            "external": true,
            "port": "3000",
            "allowed_delegate_addresses": [],
            "allowed_addresses": [],
            "allowed_ips": [],
            "command": "--bind=0.0.0.0:3000 --workers=2",
            "env": {},
            "volumes": [],
            "accepted_payments": {},
            "generates_proofs": false
        }
    ]
}
EOL

cp ~/infernet-container-starter/deploy/config.json ~/infernet-container-starter/projects/hello-world/container/config.json

echo "Creating systemd service for Ritual Network..."
cd ~/infernet-container-starter

cat > ~/ritual-service.sh << EOL
#!/bin/bash
cd ~/infernet-container-starter
echo "Starting container deployment at \$(date)" > ~/ritual-deployment.log
project=hello-world make deploy-container >> ~/ritual-deployment.log 2>&1
echo "Container deployment completed at \$(date)" >> ~/ritual-deployment.log

while true; do
  echo "Checking containers at \$(date)" >> ~/ritual-deployment.log
  if ! docker ps | grep -q "infernet"; then
    echo "Containers stopped. Restarting at \$(date)" >> ~/ritual-deployment.log
    docker compose -f deploy/docker-compose.yaml up -d >> ~/ritual-deployment.log 2>&1
  else
    echo "Containers running normally at \$(date)" >> ~/ritual-deployment.log
  fi
  sleep 300
done
EOL

chmod +x ~/ritual-service.sh

sudo tee /etc/systemd/system/ritual-network.service > /dev/null << EOL
[Unit]
Description=Ritual Network Infernet Service
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=root
ExecStart=/bin/bash /root/ritual-service.sh
Restart=always
RestartSec=30
StandardOutput=file:/root/ritual-service.log
StandardError=file:/root/ritual-service.log

[Install]
WantedBy=multi-user.target
EOL

echo "Waiting for deployment to initialize..."
sleep 10

echo "Reloading systemd daemon"
sudo systemctl daemon-reload

echo "Enabling ritual-network.service"
sudo systemctl enable ritual-network.service

echo "Starting ritual-network.service"
sudo systemctl start ritual-network.service

sleep 5

echo "Checking service status:"
sudo systemctl status ritual-network.service

echo "Ritual Network Infernet installation complete!"
sudo systemctl start ritual-network.service
