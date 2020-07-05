#!/bin/bash

set -e

mkdir -p $HOME/.kube
scp nuc1:$HOME/.kube/config $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Done!"