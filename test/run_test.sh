#!/bin/bash
set -e
set -x

IMAGE_NAME="icp-dev-env:test_temp"

# Build and run test container
echo "Building test image..."
docker build -t ${IMAGE_NAME} -f Dockerfile_test . || {
    echo "❌ Failed to build test image"
    exit 1
}

echo "Running tests..."
docker run --name icp-test ${IMAGE_NAME} || {
    echo "❌ Tests failed"
    exit 1
}

echo "✅ All tests passed successfully!"