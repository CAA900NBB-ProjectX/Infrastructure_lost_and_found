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

# Ensure Docker is running before proceeding
sleep 10

# Clone required repositories
cd /home/adminuser
mkdir -p deployment && cd deployment

declare -A repos
repos["loginservice_found_it_backend"]="https://github.com/CAA900NBB-ProjectX/loginservice_found_it_backend.git"
repos["itemservice_found_it_backend"]="https://github.com/CAA900NBB-ProjectX/itemservice_found_it_backend.git"
repos["api_gateway"]="https://github.com/CAA900NBB-ProjectX/api_gateway.git"
repos["chatservice_lost_and_found_backend"]="https://github.com/CAA900NBB-ProjectX/chatservice_lost_and_found_backend.git"

for dir in "${!repos[@]}"; do
    if [ -d "$dir" ]; then
        echo "Directory $dir exists. Pulling latest changes..."
        cd "$dir"
        git pull origin main || echo "Failed to pull latest changes"
        cd ..
    else
        echo "Cloning ${repos[$dir]} into $dir..."
        git clone "${repos[$dir]}"
    fi
done

# Deploy environment files
echo "Deploying environment files..."
echo "DATABASE_URL=mysql://user:password@localhost:3306/db" > loginservice_found_it_backend/.env
echo "DATABASE_URL=mysql://user:password@localhost:3306/db" > itemservice_found_it_backend/.env

echo "Environment files deployed successfully."

# Fix Docker permissions immediately
sudo usermod -aG docker adminuser
newgrp docker || true

# Build and run the Service Registry (Eureka)
cd /home/adminuser/deployment/api_gateway/service-registry || exit 1
echo "Building and running Service Registry (Eureka)..."

# Ensure `mvnw` is executable
chmod +x mvnw || true

# Build the project if necessary (assuming it's a Spring Boot application)
./mvnw clean package -DskipTests || exit 1

# Wait for build to complete
sleep 10

# Verify JAR file exists before proceeding
JAR_FILE=$(ls target/*.jar | head -n 1)
if [[ -z "$JAR_FILE" ]]; then
    echo "Error: JAR file not found in target/. Build failed."
    exit 1
fi

# Create a Dockerfile for Eureka (if not already in repo)
cat <<EOF > Dockerfile
FROM openjdk:11-jre-slim
WORKDIR /app
COPY $JAR_FILE service-registry.jar
EXPOSE 8761
CMD ["java", "-jar", "service-registry.jar"]
EOF

# Build Docker image for Service Registry
docker build -t service-registry .

# Remove any existing container
docker stop service-registry || true
docker rm service-registry || true

# Run Eureka Service Registry as a Docker container
docker run -d --name service-registry -p 8761:8761 service-registry

# Wait for the container to stabilize
sleep 10

# Check if container is running
if ! docker ps | grep -q service-registry; then
    echo "Error: Service Registry container failed to start."
    exit 1
fi

echo "Service Registry (Eureka) is now running on port 8761"

# Restart Docker to apply changes
sudo systemctl restart docker

# Ensure the Service Registry container starts on reboot
echo "@reboot root docker start service-registry" | sudo tee -a /etc/crontab

echo "Deployment script executed successfully."