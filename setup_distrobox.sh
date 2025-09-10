#!/bin/bash

echo "Installing Podman..."
sudo dnf install -y podman

sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER

echo "Installing Distrobox..."
sudo dnf install -y distrobox 
