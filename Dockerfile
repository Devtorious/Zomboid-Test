# Project Zomboid Dedicated Server for ARM64
# Uses Box64 and Box86 for x86_64/x86 emulation on ARM64 architecture

FROM ubuntu:22.04

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
    LOGS_DIR=/home/steamcmd/logs

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    cmake \
    build-essential \
    software-properties-common \
    lib32gcc-s1 \
    libc6:armhf \
    libncurses5:armhf \
    libstdc++6:armhf \
    libc6 \
    libstdc++6 \
    libgcc-s1 \
    libatomic1 \
    ca-certificates \
    locales \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Build and install Box64 (ARM64 -> x86_64 emulation)
RUN git clone https://github.com/ptitSeb/box64 /tmp/box64 && \
    cd /tmp/box64 && \
    mkdir build && cd build && \
    cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/box64

# Build and install Box86 (ARM64 -> x86 emulation for 32-bit support)
RUN dpkg --add-architecture armhf && \
    apt-get update && \
    apt-get install -y gcc-arm-linux-gnueabihf libc6:armhf libstdc++6:armhf && \
    git clone https://github.com/ptitSeb/box86 /tmp/box86 && \
    cd /tmp/box86 && \
    mkdir build && cd build && \
    cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/box86 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create steamcmd user and directories
RUN useradd -m -d /home/steamcmd -s /bin/bash steamcmd && \
    mkdir -p ${STEAMCMD_DIR} ${SERVER_DIR} ${CONFIG_DIR} ${SAVES_DIR} ${LOGS_DIR} && \
    chown -R steamcmd:steamcmd /home/steamcmd

# Switch to steamcmd user
USER steamcmd
WORKDIR /home/steamcmd

# Download and install SteamCMD
RUN cd ${STEAMCMD_DIR} && \
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
