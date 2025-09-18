#!/bin/bash

command_exists() {
    command -v "$1" >/dev/null 2>&1 
}

install_podman_apt() {
    echo "Installing Podman using apt..."
    sudo apt-get update
    sudo apt-get install -y podman
    
    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
}

install_podman_dnf() {
    echo "Installing Podman using dnf..."
    sudo dnf install -y podman
    
    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
}

install_distrobox_apt() {
    echo "Installing Distrobox using curl..."
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
}

install_distrobox_dnf() {
    echo "Installing Distrobox using dnf..."
    sudo dnf install -y distrobox 
}

echo "Detecting package manager..."

if command_exists apt; then
    echo "Found apt package manager (Debian/Ubuntu based system)"
    install_podman_apt
    install_distrobox_apt
    
elif command_exists dnf; then
    echo "Found dnf package manager (Fedora/RHEL based system)"
    install_podman_dnf
    install_distrobox_dnf
    
else
    echo "Error: Unsupported linux distribution!"
    echo "Please contact arungeorgesaji for more details."
    exit 1
fi

echo "Installation completed successfully!"
echo "Note: You may need to log out and log back in for user changes to take effect."
