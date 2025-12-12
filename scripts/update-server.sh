#!/bin/bash
# Update script for Project Zomboid Dedicated Server
# Updates the server using SteamCMD via Box64

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# Paths
STEAMCMD_DIR="/home/steamcmd/steamcmd"
SERVER_DIR="/home/steamcmd/server"

log "Updating Project Zomboid Dedicated Server..."

# Ensure server directory exists
if [ ! -d "${SERVER_DIR}" ]; then
    log_error "Server directory not found. Please install the server first."
    exit 1
fi

# Create SteamCMD script for update
UPDATE_SCRIPT="/tmp/update_zomboid.txt"
cat > "${UPDATE_SCRIPT}" <<EOF
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir ${SERVER_DIR}
login anonymous
app_update 380870 validate
quit
EOF

log "Running SteamCMD to update server..."
log "Using Box64 for x86_64 emulation..."

# Run SteamCMD through Box64
cd "${STEAMCMD_DIR}"
box64 ./steamcmd.sh +runscript "${UPDATE_SCRIPT}"

# Check if update was successful
if [ -f "${SERVER_DIR}/ProjectZomboid64.json" ] || [ -f "${SERVER_DIR}/start-server.sh" ]; then
    log "Server updated successfully!"
    
    # Make start-server.sh executable
    if [ -f "${SERVER_DIR}/start-server.sh" ]; then
        chmod +x "${SERVER_DIR}/start-server.sh"
    fi
else
    log_error "Update may have failed. Server files not found!"
    exit 1
fi
