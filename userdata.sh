#!/bin/bash

# Update system packages
 sudo apt update -y && sudo apt upgrade -y || sudo yum update -y
 
 # Install dependencies
 sudo apt install -y curl unzip gnupg lsb-release || sudo yum install -y curl unzip
 
 # Install Docker
 sudo apt install -y docker.io || sudo yum install -y docker
 sudo systemctl start docker
 sudo systemctl enable docker
 sudo usermod -aG docker ec2-user || sudo usermod -aG docker ubuntu

# Start Docker service and enable it to run on boot
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group so you can run docker as non-root
sudo usermod -aG docker ec2-user

# Install Docker Compose
DOCKER_COMPOSE_VERSION="1.29.2"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
-o /usr/local/bin/docker-compose

# Apply executable permissions
sudo chmod +x /usr/local/bin/docker-compose

# Create a symlink (optional, for backward compatibility)
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installations (optional)
docker --version
docker-compose --version
