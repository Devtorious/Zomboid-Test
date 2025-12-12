#!/bin/bash
# Project Zomboid Server Startup Script for ARM64
# Runs the server through Box64 emulation

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Project Zomboid Server Startup ===${NC}"

# Configuration
PZ_SERVER_DIR="${PZ_SERVER_DIR:-$HOME/pzserver}"
SERVER_NAME="${SERVER_NAME:-servertest}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-changeme}"
MEMORY="${MEMORY:-4096m}"

# Check if Box64 is installed
if ! command -v box64 &> /dev/null; then
    echo -e "${RED}Error: Box64 is not installed.${NC}"
    exit 1
fi

# Check if server directory exists
if [ ! -d "$PZ_SERVER_DIR" ]; then
    echo -e "${RED}Error: Server directory not found at $PZ_SERVER_DIR${NC}"
    echo -e "${YELLOW}Please run install-pz-server.sh first.${NC}"
    exit 1
fi

# Change to server directory
cd "$PZ_SERVER_DIR"

# Set Box64 environment variables for optimal performance
export BOX64_LOG=0
export BOX64_NOBANNER=1
export BOX64_DYNAREC_BIGBLOCK=1
export BOX64_DYNAREC_SAFEFLAGS=1
export BOX64_DYNAREC_FASTNAN=1
export BOX64_DYNAREC_FASTROUND=1
export BOX64_DYNAREC_X87DOUBLE=1
export BOX64_DYNAREC_BLEEDING_EDGE=0
export BOX64_DYNAREC_WAIT=1

# Set Steam runtime variables
export STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0
export STEAM_RUNTIME=0

# Find Java
if [ -d "$PZ_SERVER_DIR/jre64" ]; then
    JAVA_HOME="$PZ_SERVER_DIR/jre64"
    JAVA_BIN="$JAVA_HOME/bin/java"
elif command -v java &> /dev/null; then
    JAVA_BIN="java"
else
    echo -e "${RED}Error: Java not found. Please install Java 17 or higher.${NC}"
    exit 1
fi

echo -e "${GREEN}Using Java: $JAVA_BIN${NC}"
echo -e "${GREEN}Server directory: $PZ_SERVER_DIR${NC}"
echo -e "${GREEN}Server name: $SERVER_NAME${NC}"
echo -e "${GREEN}Memory allocation: $MEMORY${NC}"

# Set JVM options for Orange Pi 5 Pro
JVM_OPTS="-Xmx${MEMORY} -Xms${MEMORY}"
JVM_OPTS="$JVM_OPTS -XX:+UseG1GC"
JVM_OPTS="$JVM_OPTS -XX:+UnlockExperimentalVMOptions"
JVM_OPTS="$JVM_OPTS -XX:G1NewSizePercent=20"
JVM_OPTS="$JVM_OPTS -XX:G1ReservePercent=20"
JVM_OPTS="$JVM_OPTS -XX:MaxGCPauseMillis=50"
JVM_OPTS="$JVM_OPTS -XX:G1HeapRegionSize=32M"
JVM_OPTS="$JVM_OPTS -Djava.awt.headless=true"
JVM_OPTS="$JVM_OPTS -Dzomboid.steam=1"
JVM_OPTS="$JVM_OPTS -Dzomboid.znetlog=1"
JVM_OPTS="$JVM_OPTS -XX:+UseStringDeduplication"

# Server launch arguments
SERVER_ARGS="-servername $SERVER_NAME -adminpassword $ADMIN_PASSWORD"

# Add optional arguments if provided
if [ -n "$SERVER_IP" ]; then
    SERVER_ARGS="$SERVER_ARGS -ip $SERVER_IP"
fi

if [ -n "$SERVER_PORT" ]; then
    SERVER_ARGS="$SERVER_ARGS -port $SERVER_PORT"
fi

if [ -n "$CACHEDIR" ]; then
    SERVER_ARGS="$SERVER_ARGS -cachedir=$CACHEDIR"
fi

# Launch the server through Box64
echo -e "${YELLOW}Starting Project Zomboid server...${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo ""

# Run Java through Box64
if [ -f "$PZ_SERVER_DIR/jre64/bin/java" ]; then
    # Use bundled Java through Box64
    box64 "$PZ_SERVER_DIR/jre64/bin/java" \
        $JVM_OPTS \
        -cp "$PZ_SERVER_DIR/java/jinput.jar:$PZ_SERVER_DIR/java/*" \
        zombie.network.GameServer \
        $SERVER_ARGS
else
    # Use system Java (if it's x86_64, run through Box64)
    JAVA_ARCH=$(file -L "$JAVA_BIN" | grep -o "x86-64\|aarch64")
    if [[ "$JAVA_ARCH" == "x86-64" ]]; then
        echo -e "${YELLOW}Running x86_64 Java through Box64...${NC}"
        box64 $JAVA_BIN \
            $JVM_OPTS \
            -cp "$PZ_SERVER_DIR/java/jinput.jar:$PZ_SERVER_DIR/java/*" \
            zombie.network.GameServer \
            $SERVER_ARGS
    else
        # Native ARM64 Java
        echo -e "${GREEN}Using native ARM64 Java${NC}"
        $JAVA_BIN \
            $JVM_OPTS \
            -cp "$PZ_SERVER_DIR/java/jinput.jar:$PZ_SERVER_DIR/java/*" \
            zombie.network.GameServer \
            $SERVER_ARGS
    fi
fi
