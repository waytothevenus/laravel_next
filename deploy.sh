#!/bin/bash
set -e  # Exit on any error

echo "Stopping services..."
docker-compose -f docker-compose.yml -f docker-compose.production.yml down

# Build production containers first
echo "----------------------------------"
echo "Building production containers"
echo "----------------------------------"
docker-compose -f docker-compose.yml -f docker-compose.production.yml build composer

export DEPLOY_ID=$(date '+%s')
echo "Creating build/$DEPLOY_ID"
sudo mkdir -p "build/${DEPLOY_ID}"
sudo chown $USER:$USER "build/${DEPLOY_ID}"

# Copy application files - using absolute paths to be clear
cp -r "$(pwd)/frontend" "$(pwd)/build/${DEPLOY_ID}/"
cp -r "$(pwd)/backend" "$(pwd)/build/${DEPLOY_ID}/"

# Frontend build using the dev container
echo "----------------------------------"
echo "Building frontend"
echo "----------------------------------"
docker run -v "$(pwd)/build/$DEPLOY_ID/frontend:/app" nbts_frontend npm ci
docker run -v "$(pwd)/build/$DEPLOY_ID/frontend:/app" nbts_frontend npm run build
docker run -v "$(pwd)/build/$DEPLOY_ID/frontend:/app" nbts_frontend npm install --only=production

# Backend build and permissions
echo "----------------------------------"
echo "Building backend"
echo "----------------------------------"

# Set correct permissions on storage and cache
sudo chown -R $USER:$USER "$(pwd)/build/${DEPLOY_ID}/backend/storage"
sudo chown -R $USER:$USER "$(pwd)/build/${DEPLOY_ID}/backend/bootstrap/cache"
sudo chmod -R 775 "$(pwd)/build/${DEPLOY_ID}/backend/storage"
sudo chmod -R 775 "$(pwd)/build/${DEPLOY_ID}/backend/bootstrap/cache"

# Set permissions inside container for storage and cache
docker run --user root -v "$(pwd)/build/$DEPLOY_ID/backend:/app" nbts_composer chown -R www-data:www-data /app/storage
docker run --user root -v "$(pwd)/build/$DEPLOY_ID/backend:/app" nbts_composer chmod -R 775 /app/storage
docker run --user root -v "$(pwd)/build/$DEPLOY_ID/backend:/app" nbts_composer chown -R www-data:www-data /app/bootstrap/cache
docker run --user root -v "$(pwd)/build/$DEPLOY_ID/backend:/app" nbts_composer chmod -R 775 /app/bootstrap/cache

# Set vendor directory permissions before composer install
docker run --user root -v "$(pwd)/build/$DEPLOY_ID/backend:/app" nbts_composer chown -R www-data:www-data /app/vendor
docker run --user root -v "$(pwd)/build/$DEPLOY_ID/backend:/app" nbts_composer chmod -R 775 /app/vendor

# Run composer and artisan as www-data
docker run --user www-data:www-data -v "$(pwd)/build/$DEPLOY_ID/backend:/app" nbts_composer composer install --no-dev -o
docker run --user www-data:www-data -v "$(pwd)/build/$DEPLOY_ID/backend:/app" nbts_composer php artisan optimize
docker run --user www-data:www-data -v "$(pwd)/build/$DEPLOY_ID/backend:/app" nbts_composer php artisan route:clear

# Update symlink - point directly to the build directory
sudo rm -f ./build/latest  # Remove existing symlink if it exists
sudo ln -sfn "$(pwd)/build/${DEPLOY_ID}" "$(pwd)/build/latest"
sudo chown -R $USER:$USER ./build/latest

# Start production services
echo "----------------------------------"
echo "Starting production services"
echo "----------------------------------"
docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d

echo "Deployment completed successfully!"