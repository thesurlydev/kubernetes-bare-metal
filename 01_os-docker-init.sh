#!/bin/bash

set -e

ubuntu_version=$(lsb_release -cs) # bionic

# SUDOER_LINE="${USER}  ALL=(ALL)  NOPASSWD=ALL"
# echo "Updating sudoers..."
# echo "$SUDOER_LINE" | sudo EDITOR='tee -a' visudo

echo "Upgrading existing packages..."
sudo apt update
sudo apt upgrade -y

echo "Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${ubuntu_version} stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo systemctl status docker --no-pager

echo "Adding current user to docker group"
sudo gpasswd -a $USER docker
echo "Activating change to docker group"
newgrp docker
echo "Testing change"
docker pull hello-world

echo "Copying daemon.json"
sudo cp files/daemon.json /etc/docker/
sudo systemctl restart docker

docker info -f {{.CgroupDriver}}

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

echo "Done!"