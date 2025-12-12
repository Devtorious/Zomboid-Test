# Project Zomboid Dedicated Server for ARM64
# Uses Box64 and Box86 for x86_64/x86 emulation on ARM64 architecture

FROM ubuntu:22.04

# Build arguments for platform detection
ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH

# Labels for GitHub Container Registry
LABEL org.opencontainers.image.source="https://github.com/Devtorious/Zomboid-Test"
LABEL org.opencontainers.image.description="Project Zomboid Dedicated Server for ARM64 (CasaOS Compatible)"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="Project Zomboid ARM64 Server"
LABEL org.opencontainers.image.vendor="Devtorious"
LABEL org.opencontainers.image.documentation="https://github.com/Devtorious/Zomboid-Test/blob/main/README.md"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    BOX64_LOG=0 \
    BOX64_NOBANNER=1 \
    BOX86_LOG=0 \
    BOX86_NOBANNER=1 \
    STEAMCMD_DIR=/home/steamcmd/steamcmd \
    SERVER_DIR=/home/steamcmd/server \
    CONFIG_DIR=/home/steamcmd/config \
    SAVES_DIR=/home/steamcmd/Zomboid \
    LOGS_DIR=/home/steamcmd/logs \
    SERVER_NAME="My Zomboid Server" \
    ADMIN_PASSWORD="changeme" \
    # NOTE: ADMIN_PASSWORD must be changed via docker-compose.yml or .env file \
    SERVER_PORT=16261 \
    STEAM_PORT_1=8766 \
    STEAM_PORT_2=8767 \
    AUTO_UPDATE=true \
    MAX_PLAYERS=16 \
    SERVER_PUBLIC=false \
    PAUSE_EMPTY=true

# Show what platform we're building for and verify it's ARM64
RUN echo "Building for $TARGETPLATFORM on $BUILDPLATFORM" && \
    echo "Target architecture: $TARGETARCH" && \
    if [ "$TARGETARCH" != "arm64" ]; then \
        echo "ERROR: This Dockerfile is designed for ARM64 only, but got: $TARGETARCH"; \
        exit 1; \
    fi

# Add armhf architecture support for Box86 (32-bit ARM emulation)
RUN dpkg --add-architecture armhf && \
    echo "armhf architecture added successfully"

# Update package lists
RUN apt-get update

# Install base packages (no architecture-specific ones yet)
RUN apt-get install -y \
    wget \
    curl \
    git \
    cmake \
    build-essential \
    software-properties-common \
    ca-certificates \
    locales \
    unzip \
    openjdk-17-jre-headless

# Install ARM64 native packages
RUN apt-get install -y \
    libc6 \
    libstdc++6 \
    libgcc-s1 \
    libatomic1

# Install armhf packages (32-bit ARM) for Box86
RUN apt-get update && apt-get install -y \
    libc6:armhf \
    libncurses5:armhf \
    libstdc++6:armhf \
    libgcc-s1:armhf

# Clean up package lists
RUN rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Build and install Box64 (ARM64 -> x86_64 emulation)
RUN git clone https://github.com/ptitSeb/box64 /tmp/box64 && \
    cd /tmp/box64 && \
    mkdir build && cd build && \
    cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/box64

# Build and install Box86 (ARM64 -> x86 emulation for 32-bit support)
# Note: armhf architecture and packages already installed above
RUN apt-get update && \
    apt-get install -y gcc-arm-linux-gnueabihf && \
    git clone https://github.com/ptitSeb/box86 /tmp/box86 && \
    cd /tmp/box86 && \
    mkdir build && cd build && \
    cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/box86 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Run ldconfig to ensure box64/box86 handlers are properly registered
RUN ldconfig

# Verify that box64 is installed and working
RUN box64 -v

# Create steamcmd user and directories
RUN useradd -m -d /home/steamcmd -s /bin/bash steamcmd && \
    mkdir -p ${STEAMCMD_DIR} ${SERVER_DIR} ${CONFIG_DIR} ${SAVES_DIR} ${LOGS_DIR} && \
    chown -R steamcmd:steamcmd /home/steamcmd

# Switch to steamcmd user
USER steamcmd
WORKDIR /home/steamcmd

# Download and install SteamCMD
# Pre-create linux64 directory to encourage 64-bit version for Box64 compatibility
RUN cd ${STEAMCMD_DIR} && \
    mkdir -p linux64 && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

# Copy scripts
COPY --chown=steamcmd:steamcmd scripts/entrypoint.sh /home/steamcmd/entrypoint.sh
COPY --chown=steamcmd:steamcmd scripts/install-server.sh /home/steamcmd/install-server.sh
COPY --chown=steamcmd:steamcmd scripts/update-server.sh /home/steamcmd/update-server.sh

# Make scripts executable
RUN chmod +x /home/steamcmd/*.sh

# Expose ports
# 16261/udp - Default game port
# 16262/tcp - Additional TCP port
# 8766/udp - Steam query port
# 8767/udp - Steam port
EXPOSE 16261/udp 16262/tcp 8766/udp 8767/udp

# Define volumes
VOLUME ["${SERVER_DIR}", "${CONFIG_DIR}", "${SAVES_DIR}", "${LOGS_DIR}"]

# Set entrypoint
ENTRYPOINT ["/home/steamcmd/entrypoint.sh"]
