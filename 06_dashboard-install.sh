#!/bin/bash

set -e

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml

kubectl apply -f files/dashboard-admin-user.yaml

echo "Done!"