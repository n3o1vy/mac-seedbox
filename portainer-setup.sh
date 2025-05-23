#!/bin/bash
echo "Creating Docker volume..."
sleep 2
docker volume create portainer_data
echo "Installing Portainer server..."
sleep 2
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
echo "Checking to see if Portainer is running..."
sleep 2
docker ps
