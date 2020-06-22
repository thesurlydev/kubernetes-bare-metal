#!/bin/bash 

set -e

kubectl apply -f files/contour-v1.5.1.yaml

echo "Done!"