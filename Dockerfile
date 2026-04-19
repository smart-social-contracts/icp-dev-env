ARG PYTHON_VERSION=3.13

# Base image with Python and GLIBC 2.34 (required for candid-extractor)
FROM python:${PYTHON_VERSION}-slim-bookworm

ARG DFX_VERSION=0.30.2
ARG NODE_VERSION="22"
ARG BASILISK_VERSION="0.11.25"

# System dependencies
RUN apt-get update
RUN apt-get install -y curl ca-certificates libunwind8 build-essential

# Install Node.js
RUN apt-get install -y npm
RUN npm install -g n
RUN n ${NODE_VERSION}

# Install DFX and add to PATH
RUN DFX_VERSION=${DFX_VERSION} DFXVM_INIT_YES=true sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
ENV PATH="/root/.local/share/dfx/bin:$PATH"

# Install Basilisk
RUN pip install --no-cache-dir ic-basilisk==${BASILISK_VERSION}

# Pre-download CPython canister template for fast template-based builds
RUN mkdir -p /root/.config/basilisk/${BASILISK_VERSION} && \
    curl -fL https://github.com/smart-social-contracts/basilisk/releases/download/cpython-wasm-3.13.0/cpython_canister_template.wasm \
         -o /root/.config/basilisk/${BASILISK_VERSION}/cpython_canister_template.wasm

# Create temporary project to verify build pipeline works
WORKDIR /tmp/basilisk-init
RUN echo 'from basilisk import query\n\n@query\ndef greet() -> str:\n    return "Hello"' > main.py && \
    echo '{"canisters":{"test":{"type":"custom","build":"CANISTER_CANDID_PATH=./test.did python -m basilisk test main.py","candid":"test.did","wasm":".basilisk/test/test.wasm"}}}' > dfx.json

# Verify the build pipeline works end-to-end
RUN dfx start --background && \
    dfx deploy --no-wallet && \
    dfx stop

# Clean-ups
RUN rm -rf /tmp/basilisk-init
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# Verify installations
RUN node --version && \
    python --version && \
    dfx --version && \
    basilisk --version

# Install didc (Candid interface description language tool)
RUN curl -fsSL -o /tmp/didc-linux64 https://github.com/dfinity/candid/releases/download/2024-07-29/didc-linux64 && \
    chmod +x /tmp/didc-linux64 && \
    mv /tmp/didc-linux64 /usr/bin/didc

WORKDIR /app