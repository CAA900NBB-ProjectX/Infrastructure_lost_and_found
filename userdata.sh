#!/bin/bash

# Install Git
sudo apt install -y git

# Update system
sudo apt update -y
sudo apt install -y docker.io curl

# Enable Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker adminuser

# Install Docker Compose v1.29.2
DOCKER_COMPOSE_VERSION="1.29.2"
 sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
 -o /usr/local/bin/docker-compose

# Apply executable permissions
 sudo chmod +x /usr/local/bin/docker-compose

# Verify installations (optional)
 docker --version
 docker-compose --version

# Clone required repositories
 cd /home/adminuser
 mkdir -p deployment && cd deployment

# Clone repositories
git clone https://github.com/CAA900NBB-ProjectX/api_gateway.git
git clone https://github.com/CAA900NBB-ProjectX/loginservice_found_it_backend.git
git clone https://github.com/CAA900NBB-ProjectX/itemservice_found_it_backend.git
git clone https://github.com/CAA900NBB-ProjectX/chatservice_lost_and_found_backend.git