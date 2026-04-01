# ICP Development Environment

A Docker-based development environment on the [Internet Computer Protocol (ICP)](https://internetcomputer.org) using [Basilisk](https://github.com/smart-social-contracts/basilisk) as a Python CDK for the Internet Computer. Includes node.js for frontend development.

[![CI/CD](https://github.com/smart-social-contracts/icp-dev-env/actions/workflows/ci.yml/badge.svg)](https://github.com/smart-social-contracts/icp-dev-env/actions)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue.svg)](https://github.com/smart-social-contracts/icp-dev-env/pkgs/container/icp-dev-env)
[![License](https://img.shields.io/github/license/smart-social-contracts/icp-dev-env.svg)](https://github.com/smart-social-contracts/icp-dev-env/blob/main/LICENSE)

## Features

- **Python 3.10.7** with [**Basilisk**](https://github.com/smart-social-contracts/basilisk)
- **Pre-installed Basilisk prerequisites** - Ready to use without additional setup
- Latest versions of **Node.js 22.x** with **npm 10.x** - For frontend development
- Latest version of **icp** CLI - [Internet Computer's development toolkit](https://cli.internetcomputer.org)

## Getting Started

Pull the Docker image:
```bash
docker pull ghcr.io/smart-social-contracts/icp-dev-env:latest
```
To use a specific version, replace `:latest` with `:<version>`.

To run the image:

```bash
docker run -it --rm ghcr.io/smart-social-contracts/icp-dev-env:latest bash
```

## Usage Example

Mount your project directories and files into the container and use a custom entrypoint script:

```bash
docker run --rm -it \
    -v "${PWD}/src:/app/src" \
    -v "${PWD}/tests:/app/tests" \
    -v "${PWD}/icp.yaml:/app/icp.yaml" \
    -v "${PWD}/entrypoint.sh:/app/entrypoint.sh" \
    --entrypoint "/app/entrypoint.sh" \
    ghcr.io/smart-social-contracts/icp-dev-env:latest
```

Example `entrypoint.sh`:

```bash
#!/bin/bash

icp network start -d
sleep 10
icp deploy
# >>>>>>>>>> Add your tests here <<<<<<<<<<
icp network stop
```

## Building Locally

```bash
docker build -t icp-dev-env:test .
```

## Running Tests

The repository includes a test environment for validating the Docker image:

```bash
cd test
./run_test.sh
```

This test script:

- Initializes a clean icp network environment
- Deploys a hello canister in Basilisk and a simple frontend canister

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT](LICENSE).
