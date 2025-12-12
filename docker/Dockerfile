# Dockerfile for Project Zomboid Dedicated Server on ARM64
# Uses Box64/Box86 for x86_64 emulation

FROM ubuntu:22.04 AS builder

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    gcc-arm-linux-gnueabihf \
    python3 \
    python3-pip \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Enable armhf architecture
RUN dpkg --add-architecture armhf && apt-get update

# Build Box64
WORKDIR /tmp
RUN git clone https://github.com/ptitSeb/box64.git && \
    cd box64 && \
    mkdir build && \
    cd build && \
    cmake .. -D RK3588=1 -D CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j$(nproc) && \
    make install DESTDIR=/opt/box64-install

# Build Box86
WORKDIR /tmp
RUN git clone https://github.com/ptitSeb/box86.git && \
    cd box86 && \
    mkdir build && \
    cd build && \
    cmake .. -D RK3588=1 -D CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -j$(nproc) && \
    make install DESTDIR=/opt/box86-install

# Final image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    ca-certificates \
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6:armhf \
    libx11-6:armhf \
    libstdc++6:armhf \
    libsdl2-2.0-0:armhf \
    && dpkg --add-architecture armhf \
    && apt-get update \
    && apt-get install -y \
    libc6:armhf \
    libgdk-pixbuf2.0-0:armhf \
    libgtk2.0-0:armhf \
    && rm -rf /var/lib/apt/lists/*

# Copy Box64 and Box86 from builder
COPY --from=builder /opt/box64-install/ /
COPY --from=builder /opt/box86-install/ /

# Create box configuration directories
RUN mkdir -p /etc/box64 /etc/box86

# Configure Box64
RUN echo 'BOX64_LD_LIBRARY_PATH=~/lib/:~/lib64/:~/.steam/debian-installation/ubuntu12_32/:/usr/lib/x86_64-linux-gnu/:/lib/x86_64-linux-gnu/:/lib/i386-linux-gnu/:/usr/lib/i386-linux-gnu/' > /etc/box64/box64.conf && \
    echo 'BOX64_LOG=0' >> /etc/box64/box64.conf && \
    echo 'BOX64_NOBANNER=1' >> /etc/box64/box64.conf && \
    echo 'BOX64_DYNAREC_BIGBLOCK=1' >> /etc/box64/box64.conf && \
    echo 'BOX64_DYNAREC_SAFEFLAGS=1' >> /etc/box64/box64.conf

# Configure Box86
RUN echo 'BOX86_LD_LIBRARY_PATH=~/lib/:~/.steam/debian-installation/ubuntu12_32/:/usr/lib/i386-linux-gnu/:/lib/i386-linux-gnu/' > /etc/box86/box86.conf && \
    echo 'BOX86_LOG=0' >> /etc/box86/box86.conf && \
    echo 'BOX86_NOBANNER=1' >> /etc/box86/box86.conf

# Create zomboid user
RUN useradd -m -d /home/zomboid -s /bin/bash zomboid

USER zomboid
WORKDIR /home/zomboid

# Install SteamCMD
RUN mkdir -p /home/zomboid/steamcmd && \
    cd /home/zomboid/steamcmd && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Create SteamCMD wrapper
RUN echo '#!/bin/bash\n\
export STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0\n\
export STEAM_RUNTIME=0\n\
cd /home/zomboid/steamcmd\n\
box64 ./linux32/steamcmd "$@"' > /home/zomboid/steamcmd/run_steamcmd.sh && \
    chmod +x /home/zomboid/steamcmd/run_steamcmd.sh

# Server directories
RUN mkdir -p /home/zomboid/pzserver /home/zomboid/Zomboid/Server

# Environment variables
ENV PZ_SERVER_DIR=/home/zomboid/pzserver
ENV SERVER_NAME=servertest
ENV ADMIN_PASSWORD=changeme
ENV MEMORY=4096m
ENV BOX64_NOBANNER=1
ENV BOX64_LOG=0

# Expose ports
# 16261 UDP - Default server port
# 16262-16270 UDP - Additional server ports
EXPOSE 16261/udp 16262-16270/udp

# Volume for server data
VOLUME ["/home/zomboid/Zomboid", "/home/zomboid/pzserver"]

# Copy startup script
COPY --chown=zomboid:zomboid scripts/start-server.sh /home/zomboid/start-server.sh
RUN chmod +x /home/zomboid/start-server.sh

# Install server on first run script
COPY --chown=zomboid:zomboid scripts/install-pz-server.sh /home/zomboid/install-pz-server.sh
RUN chmod +x /home/zomboid/install-pz-server.sh

# Entry point
CMD ["/home/zomboid/start-server.sh"]
