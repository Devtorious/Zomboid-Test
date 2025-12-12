#!/bin/bash
# Installation script for Project Zomboid Dedicated Server
# Downloads and installs the server using SteamCMD via Box64

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
CONFIG_DIR="/home/steamcmd/config"

log "Installing Project Zomboid Dedicated Server..."
log "This may take a while depending on your internet connection."

# Ensure server directory exists
mkdir -p "${SERVER_DIR}"

# Create SteamCMD script for installation
INSTALL_SCRIPT="/tmp/install_zomboid.txt"
cat > "${INSTALL_SCRIPT}" <<EOF
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir ${SERVER_DIR}
login anonymous
app_update 380870 validate
quit
EOF

log "Running SteamCMD to download Project Zomboid server (App ID: 380870)..."
log "Using Box64 for x86_64 emulation..."

# Run SteamCMD - steamcmd.sh is a bash script, not a binary
# Box64 will automatically intercept the actual steamcmd binary via binfmt
cd "${STEAMCMD_DIR}"
bash ./steamcmd.sh +runscript "${INSTALL_SCRIPT}"

# Check if installation was successful
if [ -f "${SERVER_DIR}/ProjectZomboid64.json" ] || [ -f "${SERVER_DIR}/start-server.sh" ]; then
    log "Project Zomboid server installed successfully!"
    
    # Make start-server.sh executable
    if [ -f "${SERVER_DIR}/start-server.sh" ]; then
        chmod +x "${SERVER_DIR}/start-server.sh"
    fi
    
    # Create default configuration files if they don't exist in config directory
    if [ ! -f "${CONFIG_DIR}/server.ini.example" ]; then
        log "Creating example configuration files..."
        mkdir -p "${CONFIG_DIR}"
        
        # We'll create a basic example that users can customize
        cat > "${CONFIG_DIR}/server.ini.example" <<'EOFCONFIG'
# Example server.ini configuration
# Copy relevant settings from here to customize your server
# The entrypoint.sh script will create the actual server.ini in the Zomboid/Server directory

# See the existing Server/wacky.ini in this repository for a complete example
# or consult the Project Zomboid server documentation

# Basic settings:
PVP=true
PauseEmpty=true
GlobalChat=true
Open=true
MaxPlayers=16
Public=false
PublicName=My Project Zomboid Server
Password=
EOFCONFIG
        
        log "Example configuration created at ${CONFIG_DIR}/server.ini.example"
    fi
    
    log "Installation complete!"
    log "Server files are located at: ${SERVER_DIR}"
else
    log_error "Installation failed or server files not found!"
    log_error "Please check the logs above for errors."
    exit 1
fi
