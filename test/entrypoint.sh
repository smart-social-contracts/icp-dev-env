#!/bin/bash
set -e
set -x

# Start icp network in the background
echo "Starting icp network..."
icp network start -d

# Wait for icp network to be ready
echo "Waiting for icp network to start..."
sleep 10

# Deploy the hello canister
echo "Deploying hello canister..."
icp deploy

echo "Stopping icp network..."
icp network stop

echo "All done!"