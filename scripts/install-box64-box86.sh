#!/bin/bash
# Box64 and Box86 Installation Script for ARM64 (Orange Pi 5 Pro / RK3588)
# This script compiles and installs Box64 and Box86 for running x86/x86_64 applications on ARM64

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Box64 and Box86 Installation Script ===${NC}"

# Check if running on ARM64
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo -e "${RED}Error: This script must be run on ARM64 architecture. Current: $ARCH${NC}"
    exit 1
fi

echo -e "${GREEN}Detected ARM64 architecture: $ARCH${NC}"

# Update package list
echo -e "${YELLOW}Updating package list...${NC}"
sudo apt-get update

# Install build dependencies
echo -e "${YELLOW}Installing build dependencies...${NC}"
sudo apt-get install -y \
    git \
    build-essential \
    cmake \
    gcc-arm-linux-gnueabihf \
    libc6:armhf \
    libncurses5:armhf \
    libstdc++6:armhf \
    python3 \
    python3-pip

# Enable armhf architecture (needed for Box86)
echo -e "${YELLOW}Enabling armhf architecture...${NC}"
sudo dpkg --add-architecture armhf
sudo apt-get update

# Install armhf libraries for Box86
echo -e "${YELLOW}Installing armhf libraries...${NC}"
sudo apt-get install -y \
    libc6:armhf \
    libx11-6:armhf \
    libgdk-pixbuf2.0-0:armhf \
    libgtk2.0-0:armhf \
    libstdc++6:armhf \
    libsdl2-2.0-0:armhf \
    mesa-va-drivers:armhf \
    libva2:armhf

# Create build directory
BUILD_DIR="/tmp/box-build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Install Box64
echo -e "${GREEN}=== Installing Box64 ===${NC}"
if [ -d "box64" ]; then
    echo -e "${YELLOW}Removing existing Box64 directory...${NC}"
    rm -rf box64
fi

git clone https://github.com/ptitSeb/box64.git
cd box64
mkdir -p build
cd build

# Configure with RK3588 optimizations
echo -e "${YELLOW}Configuring Box64 with RK3588 optimizations...${NC}"
cmake .. -D RK3588=1 -D CMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)

echo -e "${YELLOW}Installing Box64...${NC}"
sudo make install

# Configure library paths
echo -e "${YELLOW}Configuring Box64 library paths...${NC}"
sudo mkdir -p /etc/box64
sudo bash -c 'cat > /etc/box64/box64.conf << EOF
BOX64_LD_LIBRARY_PATH=~/lib/:~/lib64/:~/.steam/debian-installation/ubuntu12_32/:/usr/lib/x86_64-linux-gnu/:/lib/x86_64-linux-gnu/:/lib/i386-linux-gnu/:/usr/lib/i386-linux-gnu/
BOX64_LOG=0
BOX64_NOBANNER=1
BOX64_DYNAREC_BIGBLOCK=1
BOX64_DYNAREC_SAFEFLAGS=1
BOX64_DYNAREC_FASTNAN=1
BOX64_DYNAREC_FASTROUND=1
BOX64_DYNAREC_X87DOUBLE=1
EOF'

# Install Box86
echo -e "${GREEN}=== Installing Box86 ===${NC}"
cd "$BUILD_DIR"
if [ -d "box86" ]; then
    echo -e "${YELLOW}Removing existing Box86 directory...${NC}"
    rm -rf box86
fi

git clone https://github.com/ptitSeb/box86.git
cd box86
mkdir -p build
cd build

# Configure with RK3588 optimizations
echo -e "${YELLOW}Configuring Box86 with RK3588 optimizations...${NC}"
cmake .. -D RK3588=1 -D CMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)

echo -e "${YELLOW}Installing Box86...${NC}"
sudo make install

# Configure library paths
echo -e "${YELLOW}Configuring Box86 library paths...${NC}"
sudo mkdir -p /etc/box86
sudo bash -c 'cat > /etc/box86/box86.conf << EOF
BOX86_LD_LIBRARY_PATH=~/lib/:~/.steam/debian-installation/ubuntu12_32/:/usr/lib/i386-linux-gnu/:/lib/i386-linux-gnu/
BOX86_LOG=0
BOX86_NOBANNER=1
BOX86_DYNAREC_BIGBLOCK=1
BOX86_DYNAREC_SAFEFLAGS=1
BOX86_DYNAREC_FASTNAN=1
BOX86_DYNAREC_FASTROUND=1
BOX86_DYNAREC_X87DOUBLE=1
EOF'

# Restart systemd-binfmt to enable Box64/Box86
echo -e "${YELLOW}Restarting systemd-binfmt...${NC}"
sudo systemctl restart systemd-binfmt

# Clean up build directory
echo -e "${YELLOW}Cleaning up build directory...${NC}"
cd ~
rm -rf "$BUILD_DIR"

# Verify installations
echo -e "${GREEN}=== Verifying Installations ===${NC}"
if command -v box64 &> /dev/null; then
    echo -e "${GREEN}Box64 installed successfully!${NC}"
    box64 -v
else
    echo -e "${RED}Box64 installation failed!${NC}"
    exit 1
fi

if command -v box86 &> /dev/null; then
    echo -e "${GREEN}Box86 installed successfully!${NC}"
    box86 -v
else
    echo -e "${RED}Box86 installation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}=== Box64 and Box86 installation complete! ===${NC}"
