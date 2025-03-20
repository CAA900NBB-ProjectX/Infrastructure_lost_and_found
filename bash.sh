#!/bin/bash

# Define repositories and their corresponding directories
declare -A repos
repos["itemservice_found_it_backend"]="https://github.com/CAA900NBB-ProjectX/itemservice_found_it_backend.git"
repos["api_gateway"]="https://github.com/CAA900NBB-ProjectX/api_gateway.git"
repos["chatservice_lost_and_found_backend"]="https://github.com/CAA900NBB-ProjectX/chatservice_lost_and_found_backend.git"
repos["loginservice_found_it_backend"]="https://github.com/CAA900NBB-ProjectX/loginservice_found_it_backend.git"

# Clone repositories
for dir in "${!repos[@]}"; do
    if [ -d "$dir" ]; then
        echo "Directory $dir already exists. Skipping clone."
    else
        echo "Cloning ${repos[$dir]} into $dir..."
        git clone "${repos[$dir]}"
    fi
done

echo "All repositories have been cloned successfully."

# Deploy environment files
echo "Deploying environment files..."
cp loginservice.env loginservice_found_it_backend/.env
cp itemservice.env itemservice_found_it_backend/.env

echo "Environment files have been deployed successfully."