#!/bin/bash

set -e  # Stop script if any command fails
set -x  # Debug mode to print commands as they run

# Add this line temporarily for debugging:
set +e

echo "Starting setup script..."

# Update system and install required packages
echo "Updating system packages..."
sudo apt update -y

echo "Installing Git, Docker, and Curl..."
sudo apt install -y git docker.io curl

# Enable and start Docker
echo "Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Add the user to the Docker group
echo "Adding adminuser to Docker group..."
sudo usermod -aG docker adminuser

# Apply group changes immediately (if running manually)
newgrp docker || echo "Please log out and log back in for Docker group changes to apply."

# Install Docker Compose v1.29.2
DOCKER_COMPOSE_VERSION="1.29.2"
echo "Installing Docker Compose version $DOCKER_COMPOSE_VERSION..."
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installations
echo "Verifying Docker and Docker Compose installation..."
docker --version || { echo "Docker installation failed!"; exit 1; }
docker-compose --version || { echo "Docker Compose installation failed!"; exit 1; }

# Ensure Docker is fully ready before running containers
echo "Waiting for Docker to fully start..."
sleep 10  # Ensures Docker daemon is ready

# # Create directory to store infrastructure files
# INFRA_DIR="/home/adminuser"
# echo "Creating infrastructure directory at $INFRA_DIR..."
# mkdir -p $INFRA_DIR

# # Download docker-compose.yml and init.sql from the repository
# echo "Downloading infrastructure files..."
# curl -o "$INFRA_DIR/docker-compose.yml" https://raw.githubusercontent.com/CAA900NBB-ProjectX/Infrastructure_lost_and_found/main/docker-compose.yml
# curl -o "$INFRA_DIR/init.sql" https://raw.githubusercontent.com/CAA900NBB-ProjectX/Infrastructure_lost_and_found/main/init.sql

# # Verify downloads
# if [[ ! -f "$INFRA_DIR/docker-compose.yml" ]]; then
#     echo "Error: docker-compose.yml not found!"
#     exit 1
# fi

# if [[ ! -f "$INFRA_DIR/init.sql" ]]; then
#     echo "Error: init.sql not found!"
#     exit 1
# fi

# # Ensure adminuser has correct permissions
# echo "Setting correct permissions..."
# sudo chown -R adminuser:adminuser "$INFRA_DIR"
# sudo chmod -R 755 "$INFRA_DIR"

# # Run Docker Compose (explicitly as adminuser)
# echo "Starting Docker containers..."
# sudo docker-compose -f /home/adminuser/docker-compose.yml --env-file /home/adminuser/.env -p app up -d
# sudo docker ps -a

# # Check if containers are running
# echo "Checking running containers..."
# sudo docker ps -aterra

# echo "Setup complete!"


# Prepare working directory
INFRA_DIR="/home/adminuser"
mkdir -p "$INFRA_DIR"

# Download files
curl -o "$INFRA_DIR/docker-compose.yml" https://raw.githubusercontent.com/CAA900NBB-ProjectX/Infrastructure_lost_and_found/main/docker-compose.yml
curl -o "$INFRA_DIR/init.sql" https://raw.githubusercontent.com/CAA900NBB-ProjectX/Infrastructure_lost_and_found/main/init.sql

# Make sure files are present
if [[ ! -f "$INFRA_DIR/docker-compose.yml" || ! -f "$INFRA_DIR/init.sql" ]]; then
  echo "Missing docker-compose or init.sql"
  exit 1
fi

# Ensure correct permissions
sudo chown -R adminuser:adminuser "$INFRA_DIR"
sudo chmod -R 755 "$INFRA_DIR"

# Wait for Docker to be fully ready
sleep 10

# Wait for .env file to exist (from Terraform null_resource)
echo "Waiting for .env to be created by Terraform..."
for i in {1..10}; do
  if [[ -f "$INFRA_DIR/.env" ]]; then
    echo ".env file found."
    break
  fi
  echo "Waiting for .env... ($i/10)"
  sleep 5
done

# Final check
if [[ ! -f "$INFRA_DIR/.env" ]]; then
  echo "ERROR: .env file not found after waiting. Aborting Docker Compose."
  exit 1
fi

echo "Cleaning up old containers (if any)..."
sudo docker rm -f postgresdb servreg apigwy loginservice itemservice chatservice || true

echo "Restarting Docker to ensure it's clean..."
sudo systemctl restart docker
sleep 10

# Start containers with Docker Compose using sudo (bypass permission issue)
sudo bash -c "cd $INFRA_DIR && docker-compose --env-file .env -p app up -d"

# Add logging to see what's going wrong
echo "Checking logs from Docker Compose..."
sudo docker-compose -f "$INFRA_DIR/docker-compose.yml" --env-file "$INFRA_DIR/.env" logs > "$INFRA_DIR/compose.log" 2>&1

# Show running containers
sudo docker ps -a

echo "Setup complete!"