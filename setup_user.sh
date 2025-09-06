#!/bin/bash

USERNAME="test_user"

PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' < /dev/urandom | head -c 15)

echo "Creating user: $USERNAME"
sudo useradd -m -G users -s /bin/bash "$USERNAME"

echo "Setting password for $USERNAME"
echo "$USERNAME:$PASSWORD" | sudo chpasswd

SUDO_GROUP=$(sudo grep -Po '^%(\w+)' /etc/sudoers /etc/sudoers.d/* 2>/dev/null | head -1 | cut -c2-)
echo "Detected sudo group: $SUDO_GROUP"

if groups "$USERNAME" | grep -q "\b$SUDO_GROUP\b"; then
    echo "Removing $USERNAME from group: $SUDO_GROUP"
    sudo deluser "$USERNAME" "$SUDO_GROUP"
else
    echo "$USERNAME is not a member of the sudo group ($SUDO_GROUP)."
fi

echo "Final group membership for $USERNAME:"
groups "$USERNAME"

echo "User setup complete for: $USERNAME"
echo "Generated password for $USERNAME is: $PASSWORD"
