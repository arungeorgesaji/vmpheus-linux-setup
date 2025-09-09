#!/bin/bash

block_settings() {
    echo "Blocking Settings app for non-root users..."
    APP_PATH=$(which gnome-control-center)
    sudo chown root:root "$APP_PATH"
    sudo chmod 700 "$APP_PATH"
    echo "Settings app is now only accessible by root"
}

setup_distrobox() {
    echo "Installing Podman..."
    sudo apt-get update
    sudo apt-get install -y podman
    
    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
    
    echo "Installing Distrobox..."
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
    echo "Distrobox setup complete"
}

echo "=== Starting System Setup ==="

block_settings
echo ""  
setup_distrobox

echo ""
echo "=== Setup Complete ==="
echo "- Settings app blocked for non-root users"
echo "- Podman and Distrobox installed"
