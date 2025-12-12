# Project Zomboid ARM64 - Quick Reference

## Quick Installation

```bash
git clone https://github.com/Devtorious/Zomboid-Test.git
cd Zomboid-Test
chmod +x install.sh
./install.sh
```

## Quick Start

```bash
# Start server (foreground)
./scripts/start-server.sh

# Start in background (screen)
screen -dmS zomboid ./scripts/start-server.sh
screen -r zomboid  # Attach to view

# Or with systemd
sudo cp systemd/zomboid-server.service /etc/systemd/system/zomboid-server@.service
sudo systemctl daemon-reload
sudo systemctl enable zomboid-server@$(whoami)
sudo systemctl start zomboid-server@$(whoami)
```

## Common Commands

### Server Management
```bash
# View systemd logs
sudo journalctl -u zomboid-server@$(whoami) -f

# Restart server
sudo systemctl restart zomboid-server@$(whoami)

# Stop server
sudo systemctl stop zomboid-server@$(whoami)
```

### Update Server
```bash
./scripts/update-server.sh
```

### Configuration Files
```
~/Zomboid/Server/servertest/servertest.ini           # Main config
~/Zomboid/Server/servertest/servertest_SandboxVars.lua  # Game rules
```

## Essential Settings

Edit `~/Zomboid/Server/servertest/servertest.ini`:

```ini
PublicName=Your Server Name
Password=optional_password
AdminPassword=CHANGE_THIS
DefaultPort=16261
MaxPlayers=16
Public=false  # true for public listing
```

## Firewall Setup

```bash
sudo ufw allow 16261/udp
sudo ufw allow 16262:16270/udp
```

## In-Game Admin Commands

```
/help                              # Show commands
/adduser "name" "pass"             # Add user
/kickuser "name"                   # Kick player
/banuser "name"                    # Ban player
/grantadmin "name"                 # Grant admin
/save                              # Save server
/quit                              # Shutdown
/servermsg "message"               # Broadcast message
/additem "player" "module.item"    # Give item
/teleport "player1" "player2"      # Teleport
```

## Performance Tuning

### Memory Allocation
Edit `scripts/start-server.sh` or set environment:
```bash
export MEMORY=4096m  # 4-8 players
export MEMORY=6144m  # 8-16 players
```

### CPU Governor (Better Performance)
```bash
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## Troubleshooting

### Check if server is running
```bash
ps aux | grep zomboid
sudo netstat -tulnp | grep 16261
```

### View logs
```bash
ls ~/Zomboid/Logs/
tail -f ~/Zomboid/Logs/server.txt
```

### Restart Box64 services
```bash
sudo systemctl restart systemd-binfmt
```

## Backup

```bash
# Manual backup
tar -czf zomboid-backup-$(date +%Y%m%d).tar.gz ~/Zomboid/Server

# Restore
tar -xzf zomboid-backup-YYYYMMDD.tar.gz -C ~/
```

## Docker Quick Start

```bash
cd docker
docker-compose build
docker-compose up -d
docker-compose logs -f
```

## Support

- Full Documentation: [README_ARM64.md](README_ARM64.md)
- Issues: https://github.com/Devtorious/Zomboid-Test/issues
- PZ Forums: https://theindiestone.com/forums/

## Key Directories

```
~/steamcmd/              # SteamCMD installation
~/pzserver/              # Server binaries
~/Zomboid/Server/        # Server data & configs
~/Zomboid/Logs/          # Server logs
```

---
**Quick Tip**: Use `screen` or `tmux` to keep the server running when disconnected!
