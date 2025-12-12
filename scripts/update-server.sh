#!/bin/bash
# Project Zomboid Server Update Script
# Updates the server files using SteamCMD

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Project Zomboid Server Update Script ===${NC}"

# Configuration
STEAMCMD_DIR="${STEAMCMD_DIR:-$HOME/steamcmd}"
PZ_SERVER_DIR="${PZ_SERVER_DIR:-$HOME/pzserver}"
PZ_APP_ID="380870"

# Check if SteamCMD is installed
if [ ! -f "$STEAMCMD_DIR/run_steamcmd.sh" ]; then
    echo -e "${RED}Error: SteamCMD is not installed at $STEAMCMD_DIR${NC}"
    exit 1
fi

# Check if server directory exists
if [ ! -d "$PZ_SERVER_DIR" ]; then
    echo -e "${RED}Error: Server directory not found at $PZ_SERVER_DIR${NC}"
    echo -e "${YELLOW}Please run install-pz-server.sh first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Backing up server...${NC}"
BACKUP_DIR="$HOME/pzserver_backups"
mkdir -p "$BACKUP_DIR"
BACKUP_NAME="pzserver_backup_$(date +%Y%m%d_%H%M%S)"

# Backup only configuration and save data
if [ -d "$HOME/Zomboid/Server" ]; then
    tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" "$HOME/Zomboid/Server" 2>/dev/null || true
    echo -e "${GREEN}Backup created: $BACKUP_DIR/$BACKUP_NAME.tar.gz${NC}"
fi

# Update server
echo -e "${YELLOW}Updating Project Zomboid Dedicated Server...${NC}"
echo -e "${YELLOW}This may take a while...${NC}"

"$STEAMCMD_DIR/run_steamcmd.sh" \
    +force_install_dir "$PZ_SERVER_DIR" \
    +login anonymous \
    +app_update "$PZ_APP_ID" validate \
    +quit

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Server updated successfully!${NC}"
    echo -e "${GREEN}You can now restart your server.${NC}"
else
    echo -e "${RED}Error: Server update failed!${NC}"
    echo -e "${YELLOW}You may want to restore from backup: $BACKUP_DIR/$BACKUP_NAME.tar.gz${NC}"
    exit 1
fi

echo -e "${GREEN}=== Update complete! ===${NC}"
