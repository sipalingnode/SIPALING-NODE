#!/bin/bash

# Function to display logo
display_logo() {
  sleep 2
  curl -s https://raw.githubusercontent.com/zamzasalim/logo/main/asc.sh | bash
  sleep 1
}

sudo ufw allow ssh
sudo ufw enable
sudo ufw status

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Installing Docker..."
  # Install Docker
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

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
  echo "Docker Compose is not installed. Installing Docker Compose..."
  # Install Docker Compose
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

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo "Git is not installed. Installing Git..."
  sudo apt update
  sudo apt install git -y
else
  echo "Git is already installed."
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "jq is not installed. Installing jq..."
  sudo apt install jq -y
else
  echo "jq is already installed."
fi

# Check if lz4 is installed
if ! command -v lz4 &> /dev/null; then
  echo "lz4 is not installed. Installing lz4..."
  sudo apt install lz4 -y
else
  echo "lz4 is already installed."
fi

# Install screen if not installed
if ! command -v screen &> /dev/null; then
  echo "screen is not installed. Installing screen..."
  sudo apt install screen -y
else
  echo "screen is already installed."
fi

# Clone Repository
echo "Cloning repository..."
git clone https://github.com/ritual-net/infernet-container-starter
cd infernet-container-starter

# Create config files
echo "Creating configuration files..."

# Ask for private key with hidden input
echo "Submit Privatekey Metamask"
read -s private_key
echo "Private key received (hidden for security)"

# Add 0x prefix if missing
if [[ ! $private_key =~ ^0x ]]; then
  private_key="0x$private_key"
  echo "Added 0x prefix to private key"
fi

# Create config.json with private key
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
        "rpc_url": "https://mainnet.base.org/",
        "registry_address": "0x3B1554f346DFe5c482Bb4BA31b880c1C18412170",
        "wallet": {
          "max_gas_limit": 4000000,
          "private_key": "${private_key}",
          "allowed_sim_errors": []
        },
        "snapshot_sync": {
          "sleep": 3,
          "batch_size": 10000,
          "starting_sub_id": 180000,
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

# Copy config to container folder
cp ~/infernet-container-starter/deploy/config.json ~/infernet-container-starter/projects/hello-world/container/config.json

# Deploy container using systemd instead of screen
echo "Creating systemd service for Ritual Network..."
cd ~/infernet-container-starter

# Create a script to be run by systemd
cat > ~/ritual-service.sh << EOL
#!/bin/bash
cd ~/infernet-container-starter
echo "Starting container deployment at \$(date)" > ~/ritual-deployment.log
project=hello-world make deploy-container >> ~/ritual-deployment.log 2>&1
echo "Container deployment completed at \$(date)" >> ~/ritual-deployment.log

# Keep containers running
cd ~/infernet-container-starter
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

# Create systemd service file
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
StandardOutput=append:/root/ritual-service.log
StandardError=append:/root/ritual-service.log

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start service
sudo systemctl daemon-reload
sudo systemctl enable ritual-network.service
sudo systemctl start ritual-network.service

# Verify service is running
sleep 5
if sudo systemctl is-active --quiet ritual-network.service; then
  echo "? Ritual Network service started successfully!"
else
  echo "?? Warning: Service might not have started correctly. Checking status..."
  sudo systemctl status ritual-network.service
fi

# Wait a bit for deployment to start
echo "Waiting for deployment to initialize..."
sleep 10

# Start containers
echo "Starting containers..."
docker compose -f deploy/docker-compose.yaml up -d

echo "Ritual Network Infernet installation complete!"