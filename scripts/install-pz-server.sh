#!/bin/bash
# Project Zomboid Server Installation Script for ARM64
# Uses SteamCMD through Box64 to download and install the server

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Project Zomboid Server Installation Script ===${NC}"

# Configuration
STEAMCMD_DIR="${STEAMCMD_DIR:-$HOME/steamcmd}"
PZ_SERVER_DIR="${PZ_SERVER_DIR:-$HOME/pzserver}"
PZ_APP_ID="380870"

# Check if SteamCMD is installed
if [ ! -f "$STEAMCMD_DIR/run_steamcmd.sh" ]; then
    echo -e "${RED}Error: SteamCMD is not installed at $STEAMCMD_DIR${NC}"
    echo -e "${YELLOW}Please run install-steamcmd.sh first.${NC}"
    exit 1
fi

echo -e "${GREEN}SteamCMD found at: $STEAMCMD_DIR${NC}"

# Create server directory
echo -e "${YELLOW}Creating Project Zomboid server directory at $PZ_SERVER_DIR${NC}"
mkdir -p "$PZ_SERVER_DIR"

# Install/Update Project Zomboid Dedicated Server
echo -e "${YELLOW}Installing Project Zomboid Dedicated Server (App ID: $PZ_APP_ID)${NC}"
echo -e "${YELLOW}This may take a while depending on your connection...${NC}"

"$STEAMCMD_DIR/run_steamcmd.sh" \
    +force_install_dir "$PZ_SERVER_DIR" \
    +login anonymous \
    +app_update "$PZ_APP_ID" validate \
    +quit

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install Project Zomboid server${NC}"
    exit 1
fi

echo -e "${GREEN}Project Zomboid server installed successfully!${NC}"

# Create server data directories
echo -e "${YELLOW}Creating server data directories...${NC}"
PZ_DATA_DIR="$HOME/Zomboid"
mkdir -p "$PZ_DATA_DIR/Server"
mkdir -p "$PZ_DATA_DIR/Logs"
mkdir -p "$PZ_DATA_DIR/db"

# Copy default configuration if config files are provided
if [ -d "$(dirname "$0")/../config" ]; then
    echo -e "${YELLOW}Copying example configuration files...${NC}"
    CONFIG_SRC="$(dirname "$0")/../config"
    
    if [ -f "$CONFIG_SRC/server.ini" ]; then
        mkdir -p "$PZ_DATA_DIR/Server/servertest"
        cp "$CONFIG_SRC/server.ini" "$PZ_DATA_DIR/Server/servertest/servertest.ini"
        echo -e "${GREEN}Copied server.ini to $PZ_DATA_DIR/Server/servertest/servertest.ini${NC}"
    fi
    
    if [ -f "$CONFIG_SRC/server_settings.ini" ]; then
        cp "$CONFIG_SRC/server_settings.ini" "$PZ_DATA_DIR/Server/servertest/servertest_SandboxVars.lua"
        echo -e "${GREEN}Copied server settings${NC}"
    fi
fi

# Set proper permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chmod -R 755 "$PZ_SERVER_DIR"

# Create symlink for easier access
if [ ! -L "$HOME/pzserver" ] && [ "$PZ_SERVER_DIR" != "$HOME/pzserver" ]; then
    ln -s "$PZ_SERVER_DIR" "$HOME/pzserver"
    echo -e "${GREEN}Created symlink: ~/pzserver -> $PZ_SERVER_DIR${NC}"
fi

# Display server information
echo -e "${GREEN}=== Installation Summary ===${NC}"
echo -e "Server files: $PZ_SERVER_DIR"
echo -e "Server data: $PZ_DATA_DIR"
echo -e "Server executable: $PZ_SERVER_DIR/start-server.sh"
echo ""
echo -e "${GREEN}=== Next Steps ===${NC}"
echo -e "1. Edit server configuration in: $PZ_DATA_DIR/Server/servertest/servertest.ini"
echo -e "2. Set admin password and server settings"
echo -e "3. Run the server with: scripts/start-server.sh"
echo -e "4. Or install as systemd service with provided systemd/zomboid-server.service"
echo ""
echo -e "${GREEN}=== Project Zomboid Server installation complete! ===${NC}"
