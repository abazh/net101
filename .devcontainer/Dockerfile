# Multi-stage build for optimized image size
FROM ubuntu:24.04 AS builder

# Build arguments for flexibility
ARG MININET_VERSION=master

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone Mininet source
RUN git clone --depth 1 --branch ${MININET_VERSION} \
    https://github.com/mininet/mininet.git /opt/mininet

# Production stage
FROM ubuntu:24.04

# Metadata labels
LABEL org.opencontainers.image.title="Mininet DevContainer" \
      org.opencontainers.image.description="Mininet DevContainer with Linux Ubuntu 24.04" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.authors="Abazh" \
      org.opencontainers.image.source="https://github.com/mininet/mininet" \
      org.opencontainers.image.licenses="MIT"

# Install runtime dependencies in optimized layers
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core system packages
    python3 \
    python3-pip \
    python-is-python3 \
    python3-termcolor \
    sudo \
    lsb-release \
    ca-certificates \
    # Networking packages
    openvswitch-switch \
    iproute2 \
    iputils-ping \
    net-tools \
    bridge-utils \
    tcpdump \
    frr \
    traceroute \
    iperf3 \
    iperf \
    socat \
    telnet \
    netcat-traditional \
    curl \
    dnsutils \
    iputils-tracepath \
    tshark \
    # Development tools
    vim \
    bc \
    git \
    zsh \
    # Additional dev tools
    procps \
    htop \
    wget \
    # Clean up in same layer
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

# Install FRR from official repository
RUN curl -s https://deb.frrouting.org/frr/keys.gpg | sudo tee /usr/share/keyrings/frrouting.gpg > /dev/null

ENV FRRVER="frr-8"
RUN echo "deb [signed-by=/usr/share/keyrings/frrouting.gpg] https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER" \
    | tee /etc/apt/sources.list.d/frr.list
RUN apt-get update && apt-get install -y frr frr-pythontools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

# Copy Mininet source from builder stage
COPY --from=builder /opt/mininet /opt/mininet

# Install Mininet with your working configuration
RUN cd /opt/mininet && \
    apt-get update && \
    # Configure pip to allow system packages (your working fix)
    pip3 config set global.break-system-packages true && \
    # Apply your Ubuntu 24.04 compatibility fix
    sed -i '181a \
if [ "$DIST" = "Ubuntu" -a $(echo "$RELEASE >= 24.04" | bc) -eq 1 ]; then\n    pf=pyflakes3\n    pep8=python3-pep8\nfi' util/install.sh && \
    # Install with your working flags
    PYTHON=python3 ./util/install.sh -nv && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /opt/mininet/.git

# Copy and set up entrypoint (keeping your working version)
COPY ../entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER root
WORKDIR /workspaces/net101

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD sudo ovs-vsctl show > /dev/null 2>&1 || exit 1

# Start OVS on container startup for devcontainer
RUN echo '#!/bin/bash\nservice openvswitch-switch start' > /usr/local/bin/start-ovs.sh && \
    chmod +x /usr/local/bin/start-ovs.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
