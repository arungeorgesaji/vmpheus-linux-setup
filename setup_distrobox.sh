#!/bin/bash

echo "Installing Podman..."
sudo apt-get update
sudo apt-get install -y podman

sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER

echo "Installing Distrobox..."
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
