#!/bin/bash
set -e
set -x

# Verify didc is installed correctly
echo "Checking didc installation..."
if didc --version; then
  echo " didc is installed correctly"
else
  echo " didc is not installed correctly"
  exit 1
fi

# Start dfx in the background
echo "Starting dfx..."
dfx start --background --clean

# Wait for dfx to be ready
echo "Waiting for dfx to start..."
sleep 10

# Deploy the hello canister
echo "Deploying hello canister..."
dfx deploy

echo "Stopping dfx..."
dfx stop

echo "All done!"