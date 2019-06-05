#!/bin/bash
# Install NvidiaGraphicsDrivers for Debian9
sudo bash -c "echo 'deb http://httpredir.debian.org/debian/ stretch main contrib non-free' >> /etc/apt/sources.list"

sudo apt update
sudo apt install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') nvidia-driver

echo "Please reboot"
