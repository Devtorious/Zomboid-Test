# Zomboid-Test

Zomboid test repo not affiliated with the people behind the game Project: Zomboid

## 🚀 ARM64 Server Setup (Orange Pi 5 Pro / RK3588)

**NEW!** Complete setup for running Project Zomboid dedicated server on ARM64 architecture.

👉 **[See ARM64 Setup Guide (README_ARM64.md)](README_ARM64.md)** for detailed instructions.

### Quick Start for ARM64

```bash
# Clone this repository
git clone https://github.com/Devtorious/Zomboid-Test.git
cd Zomboid-Test

# Run automated installation
chmod +x install.sh
./install.sh
```

This will install:
- ✅ Box64/Box86 emulation (optimized for RK3588)
- ✅ SteamCMD through emulation
- ✅ Project Zomboid Dedicated Server
- ✅ Complete configuration and startup scripts

**Platform Support:**
- ARM64 (aarch64) - Orange Pi 5 Pro, Raspberry Pi 4/5, and similar SBCs
- Ubuntu 22.04 LTS or Debian 11/12 recommended

## Server Configuration Files

This repository includes example Project Zomboid server configurations:

- `Server/wacky.ini` - Example server configuration with mods
- `Server/wacky_SandboxVars.lua` - Sandbox/game rules configuration
- `Server/wacky_spawnregions.lua` - Spawn region definitions
- `config/server.ini` - Simplified example configuration for ARM64 setup
- `config/server_settings.ini` - Game settings template

## Repository Structure

```
├── install.sh                      # ARM64 automated installation
├── scripts/                        # Installation and management scripts
│   ├── install-box64-box86.sh     # Box64/Box86 compilation
│   ├── install-steamcmd.sh        # SteamCMD setup
│   ├── install-pz-server.sh       # Server installation
│   ├── start-server.sh            # Server startup
│   └── update-server.sh           # Server update
├── config/                        # Example configurations
├── systemd/                       # Systemd service files
├── docker/                        # Docker deployment files
├── Server/                        # Example server configs
└── Saves/                         # Save file examples
```

## Documentation

- **[ARM64 Setup Guide](README_ARM64.md)** - Complete guide for ARM64 deployment
- **[Configuration Guide](README_ARM64.md#configuration)** - Server configuration help
- **[Troubleshooting](README_ARM64.md#troubleshooting)** - Common issues and solutions

## License

This setup repository is provided as-is for educational and personal use. Project Zomboid is a commercial game by The Indie Stone.
