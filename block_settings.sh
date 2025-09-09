#!/bin/bash

APP_PATH=$(which gnome-control-center)
sudo chown root:root "$APP_PATH"
sudo chmod 700 "$APP_PATH"
echo "Settings app is now blocked for non-admin users"
