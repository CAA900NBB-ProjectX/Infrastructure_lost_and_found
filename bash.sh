#!/bin/bash
set -euxo pipefail

# Navigate to workspace
cd /home/adminuser || cd /root
mkdir -p deployment && cd deployment

# Define repositories
declare -A repos
repos["itemservice_found_it_backend"]="https://github.com/CAA900NBB-ProjectX/itemservice_found_it_backend.git"
repos["api_gateway"]="https://github.com/CAA900NBB-ProjectX/api_gateway.git"
repos["chatservice_lost_and_found_backend"]="https://github.com/CAA900NBB-ProjectX/chatservice_lost_and_found_backend.git"
repos["loginservice_found_it_backend"]="https://github.com/CAA900NBB-ProjectX/loginservice_found_it_backend.git"

# Clone repositories
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
touch loginservice_found_it_backend/.env itemservice_found_it_backend/.env  # Placeholder if .env doesn't exist

echo "DATABASE_URL=mysql://user:password@localhost:3306/db" > loginservice_found_it_backend/.env
echo "DATABASE_URL=mysql://user:password@localhost:3306/db" > itemservice_found_it_backend/.env

echo "Environment files deployed successfully."
