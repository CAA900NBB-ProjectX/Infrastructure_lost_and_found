#!/bin/bash
set -eux

# Update system packages
sudo apt update -y && sudo apt upgrade -y || sudo yum update -y

# Install dependencies
sudo apt install -y curl unzip gnupg lsb-release || sudo yum install -y curl unzip

# Install Docker
sudo apt install -y docker.io || sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user || sudo usermod -aG docker ubuntu

# Install Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version

# Enable and restart Docker service
sudo systemctl enable docker
sudo systemctl restart docker

echo "Docker and Docker Compose installation completed successfully."
