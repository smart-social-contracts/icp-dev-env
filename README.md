# ICP Development Environment

A Docker-based development environment for [Smart Social Contracts](https://github.com/smart-social-contracts) on the [Internet Computer Protocol (ICP)](https://internetcomputer.org) using [Kybra](https://github.com/demergent-labs/kybra) for Python development. Includes node.js for frontend development.

## Features

- **Python 3.10.7** with [**Kybra 0.7.0**](https://github.com/demergent-labs/kybra/releases/tag/0.7.0)
- **Pre-installed Kybra prerequisites** - Ready to use without additional setup
- **Node.js 22.12.0** with **npm 10.9.2** - For frontend development
- **DFX 0.25.0** - Internet Computer's development toolkit

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

Mount your `dfx` project directories and files into the container and use a custom entrypoint script:

```bash
docker run --rm -it \
    -v "${PWD}/src:/app/src" \
    -v "${PWD}/tests:/app/tests" \
    -v "${PWD}/dfx.json:/app/dfx.json" \
    -v "${PWD}/entrypoint.sh:/app/entrypoint.sh" \
    --entrypoint "/app/entrypoint.sh" \
    ghcr.io/smart-social-contracts/icp-dev-env:latest
```

Example `entrypoint.sh`:

```bash
#!/bin/bash

dfx start --background --clean
sleep 10
dfx deploy
# >>>>>>>>>> Add your tests here <<<<<<<<<<
dfx stop
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

- Initializes a clean dfx environment
- Deploys a hello canister in Kybra and a simple frontend canister

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT](LICENSE).
