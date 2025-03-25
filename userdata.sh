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
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "Docker version: $(docker --version)"
echo "Docker-Compose version: $(docker-compose --version)"

# Create directory to store infrastructure files
mkdir -p /home/adminuser/deployment

# Download docker-compose.yml and init.sql from Infrastructure_lost_and_found repo
curl -o /home/adminuser/deployment/docker-compose.yml https://raw.githubusercontent.com/CAA900NBB-ProjectX/Infrastructure_lost_and_found/main/docker-compose.yml

curl -o /home/adminuser/deployment/init.sql https://raw.githubusercontent.com/CAA900NBB-ProjectX/Infrastructure_lost_and_found/main/init.sql

# Set ownership
sudo chown -R adminuser:adminuser /home/adminuser/deployment


# # Clone required repositories
#  cd /home/adminuser
#  mkdir -p deployment && cd deployment

# # Clone repositories
# git clone https://github.com/CAA900NBB-ProjectX/api_gateway.git
# git clone https://github.com/CAA900NBB-ProjectX/loginservice_found_it_backend.git
# git clone https://github.com/CAA900NBB-ProjectX/itemservice_found_it_backend.git
# git clone https://github.com/CAA900NBB-ProjectX/chatservice_lost_and_found_backend.git

# Set ownership so adminuser can write to cloned directories
# sudo chown -R adminuser:adminuser /home/adminuser/deployment

# # Move into each project and start services using docker-compose
# cd /home/adminuser/deployment/api_gateway/service-registry
# docker-compose -p app up -d

# cd ../api-gateway
# docker-compose -p app up -d 

# cd ../loginservice_found_it_backend

# # Create the .env file for loginservice
# cat <<EOF > .env
# EUREKA_SERVICE_CONTAINER=http://servreg:8761/eureka

# JWT_SECRET_KEY=f943ea3da5fcd77a7b78f184eaeac29d13fc20ef350edbbdb2e4c014172ee2c7e4bee4228047786ab3409b273eb048722e9227c774dd4f8fbd96ab7b438b9799

# SUPPORT_EMAIL=tharuka020395@gmail.com
# APP_PASSWORD=xcqv emma lorr lvhq

# POSTGRES_USER=postgres
# POSTGRES_PASSWORD=1250.com
# EOF

# docker-compose -p app up -d

# cd ../itemservice_found_it_backend
# docker-compose -p app up -d

# cd ../chatservice_lost_and_found_backend
# docker-compose -p app up -d