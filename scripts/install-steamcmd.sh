#!/bin/bash
# SteamCMD Installation Script for ARM64
# Installs SteamCMD to work through Box64/Box86 emulation

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== SteamCMD Installation Script ===${NC}"

# Check if Box64 is installed
if ! command -v box64 &> /dev/null; then
    echo -e "${RED}Error: Box64 is not installed. Please run install-box64-box86.sh first.${NC}"
    exit 1
fi

# Check if Box86 is installed
if ! command -v box86 &> /dev/null; then
    echo -e "${RED}Error: Box86 is not installed. Please run install-box64-box86.sh first.${NC}"
    exit 1
fi

echo -e "${GREEN}Box64 and Box86 are installed.${NC}"

# Install required dependencies for SteamCMD
echo -e "${YELLOW}Installing SteamCMD dependencies...${NC}"
sudo apt-get update
sudo apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    curl \
    tar \
    ca-certificates

# Create SteamCMD directory
STEAMCMD_DIR="$HOME/steamcmd"
echo -e "${YELLOW}Creating SteamCMD directory at $STEAMCMD_DIR${NC}"
mkdir -p "$STEAMCMD_DIR"
cd "$STEAMCMD_DIR"

# Download SteamCMD
echo -e "${YELLOW}Downloading SteamCMD...${NC}"
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Create steamcmd wrapper script for Box64
echo -e "${YELLOW}Creating SteamCMD wrapper script...${NC}"
cat > "$STEAMCMD_DIR/steamcmd.sh" << 'EOF'
#!/bin/bash
# SteamCMD wrapper for Box64

STEAMCMD_DIR="$(dirname "$(readlink -f "$0")")"
export STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0
export STEAM_RUNTIME=0

# Run steamcmd through Box64
cd "$STEAMCMD_DIR"
box64 ./steamcmd.sh.orig "$@"
EOF

# Rename original steamcmd.sh
if [ -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
    mv "$STEAMCMD_DIR/steamcmd.sh" "$STEAMCMD_DIR/steamcmd.sh.bak"
fi

# Move linux32/steamcmd to steamcmd.sh.orig
if [ -f "$STEAMCMD_DIR/linux32/steamcmd" ]; then
    cp "$STEAMCMD_DIR/linux32/steamcmd" "$STEAMCMD_DIR/steamcmd.sh.orig"
else
    echo -e "${RED}Error: steamcmd binary not found!${NC}"
    exit 1
fi

# Restore wrapper
mv "$STEAMCMD_DIR/steamcmd.sh.bak" "$STEAMCMD_DIR/steamcmd.sh"

chmod +x "$STEAMCMD_DIR/steamcmd.sh"

# Create alternative direct launch script
cat > "$STEAMCMD_DIR/run_steamcmd.sh" << 'EOF'
#!/bin/bash
# Direct SteamCMD launcher through Box64

STEAMCMD_DIR="$(dirname "$(readlink -f "$0")")"
cd "$STEAMCMD_DIR"

export STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0
export STEAM_RUNTIME=0

# Set Box64 options for better compatibility
export BOX64_LOG=0
export BOX64_NOBANNER=1
export BOX64_DYNAREC_BIGBLOCK=1

box64 ./linux32/steamcmd "$@"
EOF

chmod +x "$STEAMCMD_DIR/run_steamcmd.sh"

# Test SteamCMD
echo -e "${YELLOW}Testing SteamCMD (this may take a moment)...${NC}"
echo -e "${YELLOW}Running: +login anonymous +quit${NC}"

# Run a simple test
"$STEAMCMD_DIR/run_steamcmd.sh" +login anonymous +quit

if [ $? -eq 0 ]; then
    echo -e "${GREEN}SteamCMD test successful!${NC}"
else
    echo -e "${YELLOW}SteamCMD test completed with warnings (this is normal on first run)${NC}"
fi

# Add steamcmd to PATH (optional)
if ! grep -q "export PATH=\$PATH:$STEAMCMD_DIR" "$HOME/.bashrc"; then
    echo -e "${YELLOW}Adding SteamCMD to PATH in .bashrc${NC}"
    echo "export PATH=\$PATH:$STEAMCMD_DIR" >> "$HOME/.bashrc"
fi

echo -e "${GREEN}=== SteamCMD installation complete! ===${NC}"
echo -e "${GREEN}SteamCMD installed at: $STEAMCMD_DIR${NC}"
echo -e "${GREEN}Run with: $STEAMCMD_DIR/run_steamcmd.sh${NC}"
echo -e "${YELLOW}Note: Reload your shell or run 'source ~/.bashrc' to update PATH${NC}"
