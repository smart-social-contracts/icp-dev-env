ARG PYTHON_VERSION=3.10

# Base image with Python and GLIBC 2.34 (required for candid-extractor)
FROM python:${PYTHON_VERSION}-slim-bookworm

ARG ICP_CLI_VERSION=0.2
ARG NODE_VERSION="22"
ARG BASILISK_VERSION="0.11.2"

# System dependencies
RUN apt-get update
RUN apt-get install -y curl ca-certificates libunwind8 build-essential

# Install Node.js
RUN apt-get install -y npm
RUN npm install -g n
RUN n ${NODE_VERSION}

# Install icp CLI and add to PATH
RUN npm install -g @icp-sdk/icp-cli
ENV PATH="/root/.local/share/icp/bin:$PATH"

# Install Basilisk and prerequisites
RUN pip install --no-cache-dir ic-basilisk==${BASILISK_VERSION}
RUN python -m basilisk install-icp-extension

# Pre-download RustPython stdlib (workaround: PyPI ic-basilisk 0.8.0 builds a
# download URL using its own version against the kybra repo, but kybra has no
# 0.8.0 release. We fetch from kybra 0.7.1 where the asset actually exists.)
RUN mkdir -p /root/.config/basilisk/${BASILISK_VERSION} && \
    curl -Lf https://github.com/demergent-labs/kybra/releases/download/0.7.1/rust_python_stdlib.tar.gz \
         -o /root/.config/basilisk/${BASILISK_VERSION}/rust_python_stdlib.tar.gz && \
    tar -xf /root/.config/basilisk/${BASILISK_VERSION}/rust_python_stdlib.tar.gz \
         -C /root/.config/basilisk/${BASILISK_VERSION}/ && \
    rm /root/.config/basilisk/${BASILISK_VERSION}/rust_python_stdlib.tar.gz

# Pre-download CPython canister template for fast template-based builds
RUN curl -fL https://github.com/smart-social-contracts/basilisk/releases/download/cpython-wasm-3.13.0/cpython_canister_template.wasm \
         -o /root/.config/basilisk/${BASILISK_VERSION}/cpython_canister_template.wasm

# Create temporary project for prerequisite installation
WORKDIR /tmp/basilisk-init
RUN echo 'from basilisk import query, text\n\n@query\ndef greet() -> text:\n    return "Hello"' > main.py && \
    printf 'canisters:\n- name: test\n  build:\n    steps:\n    - type: script\n      commands:\n      - CANISTER_CANDID_PATH=.basilisk/test/test.did python -m basilisk test main.py\n      - cp .basilisk/test/test.wasm "$ICP_WASM_OUTPUT_PATH"\n' > icp.yaml

# Install prerequisites by deploying a test canister
RUN icp network start -d && \
    icp deploy && \
    icp network stop

# Clean-ups
RUN rm -rf /tmp/basilisk-init
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# Verify installations
RUN node --version && \
    python --version && \
    icp --version

WORKDIR /app