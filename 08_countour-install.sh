#!/bin/bash 

set -e

kubectl apply -f files/contour-v1.6.0.yaml

echo "Done!"