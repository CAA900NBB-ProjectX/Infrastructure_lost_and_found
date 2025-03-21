#!/bin/bash
set -euxo pipefail
exec > /var/log/userdata.log 2>&1

# Update system packages
sudo apt update -y && sudo apt upgrade -y || sudo yum update -y

# Install dependencies
sudo apt install -y curl unzip gnupg lsb-release || sudo yum install -y curl unzip

# Ensure previous Docker installations are removed
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Install Docker (Ubuntu)
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Ensure correct user is added to Docker group
if id "ubuntu" &>/dev/null; then
    sudo usermod -aG docker ubuntu
elif id "adminuser" &>/dev/null; then
    sudo usermod -aG docker adminuser
else
    echo "No valid user found to add to Docker group"
fi

# Install Docker Compose
DOCKER_COMPOSE_VERSION="2.20.2"
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then
    ARCH="x86_64"
elif [[ "$ARCH" == "aarch64" ]]; then
    ARCH="aarch64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Remove previous versions
sudo rm -f /usr/local/bin/docker-compose /usr/bin/docker-compose

# Download and install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installations
docker --version || echo "Docker installation failed!"
docker-compose --version || echo "Docker Compose installation failed!"

# Restart Docker service
sudo systemctl enable docker
sudo systemctl restart docker

# Download and execute `bash.sh`
cd /home/adminuser || cd /root
curl -O https://raw.githubusercontent.com/CAA900NBB-ProjectX/deployment-scripts/main/bash.sh
chmod +x bash.sh
sudo -u adminuser ./bash.sh


echo "Deployment script executed successfully."
