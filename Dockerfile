ARG PYTHON_VERSION=3.10

# Base image with Python and GLIBC 2.34 (required for candid-extractor)
FROM python:${PYTHON_VERSION}-slim-bookworm

ARG DFX_VERSION=0.27.0
ARG NODE_VERSION="22"
ARG KYBRA_VERSION="0.7.1"

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

# Install Kybra and prerequisites
RUN pip install --no-cache-dir kybra==${KYBRA_VERSION}
RUN python -m kybra install-dfx-extension

# Create temporary project for prerequisite installation
WORKDIR /tmp/kybra-init
RUN echo 'from kybra import query, text\n\n@query\ndef greet() -> text:\n    return "Hello"' > main.py && \
    echo '{"canisters":{"test":{"type":"kybra","main":"main.py"}}}' > dfx.json

# Install prerequisites by deploying a test canister
RUN dfx start --background && \
    dfx deploy --no-wallet && \
    dfx stop

# Clean-ups
RUN rm -rf /tmp/kybra-init
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# Verify installations
RUN node --version && \
    python --version && \
    dfx --version

WORKDIR /app