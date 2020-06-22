#!/bin/bash

set -e

echo "Disabling swap"
sudo swapoff -a

echo "Installing kubelet, kubeadm, and kubectl"
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo mkdir -p /var/lib/kubelet
sudo cp files/config.yaml /var/lib/kubelet/

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg2

sudo cp files/kubeadm-flags.env /var/lib/kubelet/

echo ""
echo "Reminder: Update /etc/fstab to disable swap"
echo ""
echo "Done!"
