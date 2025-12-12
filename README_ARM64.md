# Project Zomboid Dedicated Server for ARM64

Complete setup for running a Project Zomboid dedicated server on ARM64 architecture, specifically optimized for the **Orange Pi 5 Pro** (RK3588). This solution uses Box64/Box86 emulation to run the x86_64 SteamCMD and Project Zomboid server on ARM64 hardware.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Manual Installation](#manual-installation)
- [Configuration](#configuration)
- [Running the Server](#running-the-server)
- [Systemd Service](#systemd-service)
- [Docker Deployment](#docker-deployment)
- [Port Forwarding](#port-forwarding)
- [Performance Tuning](#performance-tuning)
- [Updating the Server](#updating-the-server)
- [Troubleshooting](#troubleshooting)
- [Admin Commands](#admin-commands)
- [Backup and Restore](#backup-and-restore)

## Overview

This project provides a complete, automated setup for running a Project Zomboid dedicated server on ARM64 systems. The main challenge is that Project Zomboid uses SteamCMD, which is an x86/x86_64 application. We solve this using:

- **Box64**: Emulates 64-bit x86_64 applications on ARM64
- **Box86**: Emulates 32-bit x86 applications on ARM64 (needed for some Steam dependencies)
- **Optimized configuration**: Specifically tuned for RK3588 (Orange Pi 5 Pro)

### System Architecture

```
ARM64 Hardware (Orange Pi 5 Pro)
    ↓
Box64/Box86 Emulation Layer
    ↓
SteamCMD (x86_64)
    ↓
Project Zomboid Server (x86_64)
```

## Prerequisites

### Hardware Requirements

- **Recommended**: Orange Pi 5 Pro or similar ARM64 SBC with RK3588
- **Minimum RAM**: 4GB (8GB+ recommended for larger servers)
- **Storage**: 10GB+ free space (server files ~3GB, save data grows over time)
- **Network**: Stable internet connection, ability to forward ports

### Software Requirements

- **OS**: Ubuntu 22.04 LTS ARM64 or Debian 11/12 ARM64
- **Architecture**: ARM64 (aarch64)
- **Kernel**: Linux 5.10+
- **Sudo access** for installation

### Recommended OS Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install basic utilities
sudo apt install -y git curl wget nano htop
```

## Quick Start

The fastest way to get started is to use the automated installation script:

```bash
# Clone this repository
git clone https://github.com/Devtorious/Zomboid-Test.git
cd Zomboid-Test

# Make installation script executable
chmod +x install.sh

# Run the installation
./install.sh
```

The installation script will:
1. ✅ Install Box64 and Box86 with RK3588 optimizations
2. ✅ Install and configure SteamCMD
3. ✅ Download Project Zomboid server files (~3GB)
4. ✅ Set up configuration files

**Installation time**: 30-60 minutes (depending on your internet connection and CPU)

## Manual Installation

If you prefer to install components individually:

### Step 1: Install Box64 and Box86

```bash
chmod +x scripts/install-box64-box86.sh
./scripts/install-box64-box86.sh
```

This will compile and install both emulators with RK3588-specific optimizations.

### Step 2: Install SteamCMD

```bash
chmod +x scripts/install-steamcmd.sh
./scripts/install-steamcmd.sh
```

### Step 3: Install Project Zomboid Server

```bash
chmod +x scripts/install-pz-server.sh
./scripts/install-pz-server.sh
```

### Step 4: Make Scripts Executable

```bash
chmod +x scripts/start-server.sh
chmod +x scripts/update-server.sh
```

## Configuration

### Server Configuration File

The main configuration file is located at:
```
~/Zomboid/Server/servertest/servertest.ini
```

You can use the provided example:
```bash
cp config/server.ini ~/Zomboid/Server/servertest/servertest.ini
```

### Important Settings to Configure

Edit `~/Zomboid/Server/servertest/servertest.ini`:

```ini
# Server Identity
PublicName=My PZ Server
PublicDescription=A friendly survival server

# Security
Password=mypassword            # Leave empty for no password
AdminPassword=supersecret      # IMPORTANT: Change this!

# Network
DefaultPort=16261              # Default game port
Public=false                   # Set to true for public servers

# Players
MaxPlayers=16                  # Max players (32 max, but consider performance)

# Map
Map=Muldraugh, KY             # Or Louisville, KY, etc.
```

### Game Rules Configuration

Sandbox variables are in:
```
~/Zomboid/Server/servertest/servertest_SandboxVars.lua
```

Example template provided at `config/server_settings.ini`

### Environment Variables

You can customize the server startup by setting these environment variables:

```bash
export SERVER_NAME=servertest        # Server instance name
export ADMIN_PASSWORD=changeme       # Admin password
export MEMORY=4096m                  # JVM memory allocation
export PZ_SERVER_DIR=$HOME/pzserver  # Server installation directory
```

## Running the Server

### Manual Start

```bash
cd Zomboid-Test
./scripts/start-server.sh
```

The server will start in the foreground. Press `Ctrl+C` to stop.

### Background Start with Screen

```bash
# Install screen if not available
sudo apt install screen

# Start in a detached screen session
screen -dmS zomboid ./scripts/start-server.sh

# Attach to see logs
screen -r zomboid

# Detach from screen: Ctrl+A, then D
```

### Background Start with tmux

```bash
# Install tmux if not available
sudo apt install tmux

# Start in a detached tmux session
tmux new-session -d -s zomboid './scripts/start-server.sh'

# Attach to see logs
tmux attach -t zomboid

# Detach from tmux: Ctrl+B, then D
```

## Systemd Service

For production use, it's recommended to run the server as a systemd service:

### Installation

```bash
# Copy service file (replace 'username' with your actual username)
sudo cp systemd/zomboid-server.service /etc/systemd/system/zomboid-server@.service

# Reload systemd
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable zomboid-server@$(whoami)

# Start the service
sudo systemctl start zomboid-server@$(whoami)
```

### Service Management

```bash
# Check status
sudo systemctl status zomboid-server@$(whoami)

# View logs
sudo journalctl -u zomboid-server@$(whoami) -f

# Stop server
sudo systemctl stop zomboid-server@$(whoami)

# Restart server
sudo systemctl restart zomboid-server@$(whoami)
```

## Docker Deployment

### Build and Run with Docker Compose

```bash
# Build the image
docker-compose -f docker/docker-compose.yml build

# Start the server
docker-compose -f docker/docker-compose.yml up -d

# View logs
docker-compose -f docker/docker-compose.yml logs -f

# Stop the server
docker-compose -f docker/docker-compose.yml down
```

### Manual Docker Build

```bash
# Build image
docker build -t zomboid-server-arm64 -f docker/Dockerfile .

# Run container
docker run -d \
  --name zomboid-server \
  --network host \
  -e SERVER_NAME=servertest \
  -e ADMIN_PASSWORD=changeme \
  -e MEMORY=4096m \
  -v ./server-data/Zomboid:/home/zomboid/Zomboid \
  -v ./server-data/pzserver:/home/zomboid/pzserver \
  zomboid-server-arm64
```

## Port Forwarding

### Required Ports

The server uses the following ports (all UDP):

- **16261**: Main game port (DefaultPort)
- **16262-16270**: Additional connection ports

### Firewall Configuration

#### UFW (Ubuntu/Debian)

```bash
sudo ufw allow 16261/udp
sudo ufw allow 16262:16270/udp
sudo ufw status
```

#### iptables

```bash
sudo iptables -A INPUT -p udp --dport 16261 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 16262:16270 -j ACCEPT
```

### Router Port Forwarding

Configure your router to forward these ports to your Orange Pi's local IP address:
- External Port: 16261 UDP → Internal Port: 16261 (your Orange Pi IP)
- External Ports: 16262-16270 UDP → Internal Ports: 16262-16270 (your Orange Pi IP)

## Performance Tuning

### Orange Pi 5 Pro Specific

The Orange Pi 5 Pro (RK3588) has excellent performance for this task:
- 8-core CPU (4x Cortex-A76 @ 2.4GHz + 4x Cortex-A55 @ 1.8GHz)
- Up to 16GB RAM

### Memory Settings

Adjust based on your RAM and player count:

```bash
# 4-8 players
export MEMORY=2048m

# 8-16 players
export MEMORY=4096m

# 16-32 players
export MEMORY=6144m
```

Edit in `scripts/start-server.sh` or set before running.

### Box64 Optimizations

The installation already includes RK3588-specific optimizations:
- `BOX64_DYNAREC_BIGBLOCK=1` - Larger translation blocks
- `BOX64_DYNAREC_SAFEFLAGS=1` - Optimized flag handling
- `BOX64_DYNAREC_FASTNAN=1` - Fast NaN handling
- `BOX64_DYNAREC_FASTROUND=1` - Fast rounding

### CPU Governor

For best performance, use the performance governor:

```bash
# Check current governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Set to performance (temporary)
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Make permanent (add to /etc/rc.local or create systemd service)
```

### Storage Optimization

Use fast storage for best performance:
- **Best**: NVMe SSD via PCIe
- **Good**: High-quality microSD card (A2, UHS-3)
- **Acceptable**: eMMC

## Updating the Server

### Manual Update

```bash
./scripts/update-server.sh
```

This script will:
1. Backup your server configuration
2. Download and validate server updates
3. Preserve your save data and settings

### Automatic Updates

Add to crontab for weekly updates:

```bash
crontab -e
```

Add this line:
```
0 4 * * 0 /home/yourusername/Zomboid-Test/scripts/update-server.sh
```

## Troubleshooting

### Common Issues

#### 1. Box64/Box86 Not Found

```bash
# Verify installation
which box64
which box86

# Reinstall if needed
./scripts/install-box64-box86.sh
```

#### 2. SteamCMD Fails to Login

```bash
# Try manual test
~/steamcmd/run_steamcmd.sh +login anonymous +quit

# Check Box64 logs
export BOX64_LOG=1
~/steamcmd/run_steamcmd.sh +login anonymous +quit
```

#### 3. Server Won't Start

Check the logs:
```bash
# If using systemd
sudo journalctl -u zomboid-server@$(whoami) -n 100

# If running manually, check output
```

Common causes:
- Wrong Java version (need Java 17+)
- Insufficient memory
- Port already in use

#### 4. Poor Performance

- Increase memory allocation
- Check CPU temperature: `sensors` or `cat /sys/class/thermal/thermal_zone0/temp`
- Reduce max players
- Use performance CPU governor
- Check for other processes consuming resources: `htop`

#### 5. Connection Issues

```bash
# Test if server is listening
sudo netstat -tulnp | grep 16261

# Check firewall
sudo ufw status

# Test from another machine
nc -u -v YOUR_SERVER_IP 16261
```

### Debug Mode

Enable verbose logging:

```bash
# In scripts/start-server.sh, add:
export BOX64_LOG=2
export BOX64_TRACE=1
```

### Getting Help

- Check server logs in `~/Zomboid/Logs/`
- Project Zomboid forums: https://theindiestone.com/forums/
- Box64 GitHub: https://github.com/ptitSeb/box64
- This repository issues: [Create an issue](https://github.com/Devtorious/Zomboid-Test/issues)

## Admin Commands

### In-Game Console

Press `/` to open chat, then use these commands:

#### Player Management
```
/help - Show all commands
/adduser "username" "password" - Add new user
/kickuser "username" - Kick player
/banuser "username" - Ban player
/unbanuser "username" - Unban player
/grantadmin "username" - Grant admin privileges
/removeadmin "username" - Remove admin privileges
```

#### Server Management
```
/save - Save server state
/quit - Shutdown server
/servermsg "message" - Send message to all players
/setaccesslevel "username" "admin/moderator/overseer/gm/observer" - Set access level
```

#### Teleportation
```
/teleport "player1" "player2" - Teleport player1 to player2
/teleportto x,y,z - Teleport yourself to coordinates
```

#### Items and Skills
```
/additem "player" "module.item" - Give item to player
/addvehicle "script" - Spawn vehicle
/addxp "player" "perk" amount - Add XP
```

### Server Configuration (RCON)

If RCON is enabled in server.ini:

```bash
# Install RCON tool
sudo apt install rcon

# Connect
rcon -H localhost -p 27015 -P your_rcon_password
```

## Backup and Restore

### Manual Backup

```bash
# Backup server data
tar -czf zomboid-backup-$(date +%Y%m%d).tar.gz ~/Zomboid/Server

# Backup entire installation
tar -czf zomboid-full-backup-$(date +%Y%m%d).tar.gz ~/Zomboid ~/pzserver
```

### Automated Backup Script

Create `~/backup-zomboid.sh`:

```bash
#!/bin/bash
BACKUP_DIR=~/zomboid-backups
mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/zomboid-$(date +%Y%m%d-%H%M%S).tar.gz ~/Zomboid/Server
# Keep only last 7 backups
ls -t $BACKUP_DIR/zomboid-*.tar.gz | tail -n +8 | xargs rm -f
```

Add to crontab:
```bash
0 2 * * * ~/backup-zomboid.sh
```

### Restore from Backup

```bash
# Stop server first
sudo systemctl stop zomboid-server@$(whoami)

# Restore
tar -xzf zomboid-backup-YYYYMMDD.tar.gz -C ~/

# Start server
sudo systemctl start zomboid-server@$(whoami)
```

## Performance Benchmarks

Approximate performance on Orange Pi 5 Pro:

| Players | Memory | CPU Usage | Status |
|---------|--------|-----------|--------|
| 1-4     | 2GB    | 10-20%    | ✅ Excellent |
| 5-8     | 4GB    | 20-35%    | ✅ Very Good |
| 9-16    | 6GB    | 35-50%    | ✅ Good |
| 17-24   | 8GB    | 50-70%    | ⚠️ Playable |
| 25-32   | 10GB+  | 70-90%    | ⚠️ Heavy Load |

*Note: Actual performance depends on mods, world size, and gameplay activity*

## Credits and Links

### Project Zomboid
- Website: https://projectzomboid.com/
- Wiki: https://pzwiki.net/

### Emulation Tools
- Box64: https://github.com/ptitSeb/box64
- Box86: https://github.com/ptitSeb/box86

### Community
- Official Forums: https://theindiestone.com/forums/
- Reddit: https://www.reddit.com/r/projectzomboid/
- Discord: Check official website for invite

## License

This setup repository is provided as-is for educational and personal use. Project Zomboid is a commercial game by The Indie Stone. Please support the developers by purchasing the game.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Changelog

### Version 1.0.0 (Initial Release)
- Complete automated installation for ARM64
- Box64/Box86 compilation with RK3588 optimizations
- SteamCMD setup and wrapper scripts
- Server installation and update scripts
- Systemd service configuration
- Docker deployment option
- Comprehensive documentation

---

**Enjoy your Project Zomboid server on ARM64! 🧟**
