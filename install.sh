#!/bin/bash
# Main Installation Script for Project Zomboid Server on ARM64
# This script orchestrates the complete installation process

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Project Zomboid Dedicated Server Setup for ARM64         ║${NC}"
echo -e "${BLUE}║  Orange Pi 5 Pro / RK3588 Optimized                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check architecture
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo -e "${RED}Error: This installation is designed for ARM64 architecture.${NC}"
    echo -e "${RED}Current architecture: $ARCH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ ARM64 architecture detected${NC}"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}Warning: Running as root is not recommended.${NC}"
    echo -e "${YELLOW}The server should run as a regular user.${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Installation steps
echo -e "\n${BLUE}Installation will proceed in the following steps:${NC}"
echo -e "1. Install Box64 and Box86 (x86/x86_64 emulation layer)"
echo -e "2. Install SteamCMD"
echo -e "3. Download and install Project Zomboid Dedicated Server"
echo -e "4. Configure server settings"
echo ""
read -p "Continue with installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

# Step 1: Install Box64 and Box86
echo -e "\n${BLUE}═══ Step 1/4: Installing Box64 and Box86 ═══${NC}"
if command -v box64 &> /dev/null && command -v box86 &> /dev/null; then
    echo -e "${GREEN}Box64 and Box86 are already installed.${NC}"
    read -p "Reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "$SCRIPT_DIR/scripts/install-box64-box86.sh"
    fi
else
    bash "$SCRIPT_DIR/scripts/install-box64-box86.sh"
fi

# Step 2: Install SteamCMD
echo -e "\n${BLUE}═══ Step 2/4: Installing SteamCMD ═══${NC}"
STEAMCMD_DIR="$HOME/steamcmd"
if [ -f "$STEAMCMD_DIR/run_steamcmd.sh" ]; then
    echo -e "${GREEN}SteamCMD is already installed.${NC}"
    read -p "Reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "$SCRIPT_DIR/scripts/install-steamcmd.sh"
    fi
else
    bash "$SCRIPT_DIR/scripts/install-steamcmd.sh"
fi

# Step 3: Install Project Zomboid Server
echo -e "\n${BLUE}═══ Step 3/4: Installing Project Zomboid Server ═══${NC}"
bash "$SCRIPT_DIR/scripts/install-pz-server.sh"

# Step 4: Configuration
echo -e "\n${BLUE}═══ Step 4/4: Server Configuration ═══${NC}"
echo -e "${YELLOW}Server configuration files are located at:${NC}"
echo -e "  ~/Zomboid/Server/servertest/servertest.ini"
echo ""
echo -e "${YELLOW}Important settings to configure:${NC}"
echo -e "  - Admin password"
echo -e "  - Server name"
echo -e "  - Server password (optional)"
echo -e "  - Port settings (default: 16261)"
echo ""
read -p "Edit server configuration now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v nano &> /dev/null; then
        nano "$HOME/Zomboid/Server/servertest/servertest.ini"
    elif command -v vi &> /dev/null; then
        vi "$HOME/Zomboid/Server/servertest/servertest.ini"
    else
        echo -e "${YELLOW}No text editor found. Please edit manually.${NC}"
    fi
fi

# Installation complete
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation Complete!                                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Configure your server settings:"
echo -e "   ${YELLOW}nano ~/Zomboid/Server/servertest/servertest.ini${NC}"
echo ""
echo -e "2. Start the server:"
echo -e "   ${YELLOW}bash $SCRIPT_DIR/scripts/start-server.sh${NC}"
echo ""
echo -e "3. Or install as systemd service:"
echo -e "   ${YELLOW}sudo cp $SCRIPT_DIR/systemd/zomboid-server.service /etc/systemd/system/${NC}"
echo -e "   ${YELLOW}sudo systemctl daemon-reload${NC}"
echo -e "   ${YELLOW}sudo systemctl enable zomboid-server${NC}"
echo -e "   ${YELLOW}sudo systemctl start zomboid-server${NC}"
echo ""
echo -e "4. Configure firewall (if needed):"
echo -e "   ${YELLOW}sudo ufw allow 16261/udp${NC}"
echo -e "   ${YELLOW}sudo ufw allow 16262:16270/udp${NC}"
echo ""
echo -e "${BLUE}For more information, see README.md${NC}"
echo ""
