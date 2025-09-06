#!/bin/bash

USERNAME="test_user"

SCRIPT_URL="https://raw.githubusercontent.com/arungeorgesaji/vmpheus-linux-setup/main/send_heartbeats.sh"
SCRIPT_PATH="/usr/local/bin/send_heartbeats.sh"  
SERVICE_FILE="/etc/systemd/system/heartbeats-${USERNAME}.service"

if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo"
    exit 1
fi

if ! id "$USERNAME" &>/dev/null; then
    echo "Error: User '$USERNAME' does not exist"
    exit 1
fi

echo "Setting up heartbeats activity monitor for user: $USERNAME"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Downloading heartbeat script..."
    if command -v curl &> /dev/null; then
        curl -s -o "$SCRIPT_PATH" "$SCRIPT_URL"
    elif command -v wget &> /dev/null; then
        wget -q -O "$SCRIPT_PATH" "$SCRIPT_URL"
    else
        echo "Error: Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "Error: Failed to download the heartbeat script"
        exit 1
    fi

    chmod 755 "$SCRIPT_PATH"  
    chown root:root "$SCRIPT_PATH"
else
    echo "Heartbeat script already exists, skipping download"
fi

echo "Creating systemd service for $USERNAME..."
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Heartbeats Activity Monitor for $USERNAME
After=network.target graphical.target

[Service]
Type=simple
User=$USERNAME
Environment=DISPLAY=:0
ExecStart=$SCRIPT_PATH
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

chmod 644 "$SERVICE_FILE"  
chown root:root "$SERVICE_FILE"

echo "Enabling and starting service for $USERNAME..."
systemctl daemon-reload
systemctl enable "heartbeats-${USERNAME}.service"
systemctl start "heartbeats-${USERNAME}.service"

echo "Setup completed successfully for $USERNAME!"
echo "Service status: $(systemctl is-active heartbeats-${USERNAME}.service)"
echo "Service enabled: $(systemctl is-enabled heartbeats-${USERNAME}.service)"
