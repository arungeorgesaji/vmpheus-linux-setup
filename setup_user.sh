#!/bin/bash

if [ $# -eq 0 ]; then
    echo "This script requires one argument [username]"
    exit 1
elif [ $# -gt 1 ]; then
    echo "This script only accepts one argument [username]"
    exit 1
fi

USERNAME="$1"
SCRIPT_URL="https://raw.githubusercontent.com/arungeorgesaji/vmpheus-linux-setup/main/send_heartbeats.sh"
SCRIPT_PATH="/usr/local/bin/send_heartbeats-${USERNAME}.sh"  
SERVICE_FILE="/etc/systemd/system/heartbeats-${USERNAME}.service"

if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo"
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    echo "Error: User '$USERNAME' already exists."
    exit 1
fi

PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' < /dev/urandom | head -c 15)

echo "Creating user: $USERNAME"
useradd -m -G users -s /bin/bash "$USERNAME"

echo "Setting password for $USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

echo "Setting proper home directory permissions..."
chmod 700 /home/$USERNAME
chown $USERNAME:$USERNAME /home/$USERNAME

SUDO_GROUP=$(grep -Po '^%(\w+)' /etc/sudoers /etc/sudoers.d/* 2>/dev/null | head -1 | cut -c2- || echo "sudo")
echo "Detected sudo group: $SUDO_GROUP"

if groups "$USERNAME" | grep -q "\b$SUDO_GROUP\b"; then
    echo "Removing $USERNAME from group: $SUDO_GROUP"
    deluser "$USERNAME" "$SUDO_GROUP"
else
    echo "$USERNAME is not a member of the sudo group ($SUDO_GROUP)."
fi

echo "Final group membership for $USERNAME:"
groups "$USERNAME"

echo "Setting up heartbeats activity monitor for user: $USERNAME"

echo "Downloading heartbeat script for $USERNAME..."
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

sed -i "s/^USERNAME=.*/USERNAME=\"$USERNAME\"/" "$SCRIPT_PATH"

chmod 755 "$SCRIPT_PATH"  
chown root:root "$SCRIPT_PATH"

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

echo "User setup complete for: $USERNAME"
echo "Generated password for $USERNAME is: $PASSWORD"
echo "Script location: $SCRIPT_PATH"
echo "Service file: $SERVICE_FILE"
