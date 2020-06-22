#!/bin/bash

set -e

kubeadm join 192.168.7.121:6443 --token 16qle1.kh5tj4n3i0vwyorc     --discovery-token-ca-cert-hash sha256:4f3127b9a9f6b9ddd5b9f49a993758f727fb9db0b727633ebb56cc9cf8ae07b5

