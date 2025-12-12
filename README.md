# Project Zomboid Dedicated Server for ARM64 (CasaOS Compatible)

![Project Zomboid](https://steamcdn-a.akamaihd.net/steam/apps/108600/header.jpg)

Run a **Project Zomboid dedicated server** on ARM64 devices (Orange Pi 5 Pro, Raspberry Pi 4/5, etc.) using Docker and Box64/Box86 for x86_64 to ARM64 architecture translation.

Fully compatible with **CasaOS** for easy deployment and management through a web interface.

> **Note**: This is a community project, not officially affiliated with The Indie Stone (makers of Project Zomboid).

## 🎯 Features

- ✅ **Full ARM64 Support** - Runs on Orange Pi, Raspberry Pi, and other ARM64 devices
- ✅ **Box64/Box86 Emulation** - Transparent x86_64 to ARM64 translation
- ✅ **CasaOS Integration** - Easy deployment and management
- ✅ **Automatic Updates** - Optional auto-update on container restart
- ✅ **Workshop Mod Support** - Install mods from Steam Workshop
- ✅ **Persistent Data** - Separate volumes for saves, config, and server files
- ✅ **Easy Configuration** - Environment variables for all settings
- ✅ **Resource Optimized** - Tuned for ARM64 performance

## 📋 Prerequisites

### Hardware Requirements
- **ARM64 Device**: Orange Pi 5 Pro, Raspberry Pi 4/5, or similar
- **RAM**: Minimum 4GB (6-8GB recommended)
- **Storage**: 10GB free space (5GB for server, 5GB for saves/backups)
- **Network**: Stable internet connection for downloads and multiplayer

### Software Requirements
- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 1.29 or higher
- **CasaOS** (optional): For easy web-based management
- **Operating System**: Any ARM64 Linux distribution

## 🚀 Quick Start

### Method 1: Using Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/Devtorious/Zomboid-Test.git
   cd Zomboid-Test
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   nano .env  # or use your preferred editor
   ```
   
   **IMPORTANT**: Change `ADMIN_PASSWORD` from `changeme` to a strong password!

3. **Start the server**
   ```bash
   docker-compose up -d
   ```

4. **Monitor the installation**
   ```bash
   docker-compose logs -f
   ```
   
   First startup downloads ~2-3GB and can take 10-30 minutes depending on your connection.

5. **Connect to your server**
   - Open Project Zomboid
   - Go to "Join" → "Server Browser"
   - Find your server by name or add it manually using your IP and port 16261

### Method 2: Using CasaOS

1. **Import via Docker Compose**
   - In CasaOS, go to the App Store
   - Click "Import" or "Custom Install"
   - Select the `docker-compose.yml` file from this repository
   - Configure environment variables in the CasaOS UI
   - Click "Install"

2. **Or use the CasaOS App Store YAML**
   - Copy the contents of `casa-app.yml`
   - In CasaOS, create a custom app store entry
   - The app will appear in your CasaOS app store

3. **Monitor in CasaOS**
   - View logs, resource usage, and manage the container from the CasaOS dashboard

## ⚙️ Configuration

### Environment Variables

All configuration is done through environment variables in the `.env` file:

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_NAME` | My Project Zomboid Server | Server name in browser |
| `SERVER_PASSWORD` | _(empty)_ | Password to join (leave empty for open server) |
| `ADMIN_PASSWORD` | changeme | **CHANGE THIS!** Admin password |
| `MAX_PLAYERS` | 16 | Maximum players (1-100, 16 recommended for ARM64) |
| `SERVER_PUBLIC` | false | Show in public server list |
| `PAUSE_EMPTY` | true | Pause game when no players online |
| `AUTO_UPDATE` | true | Auto-update server on restart |
| `MEMORY` | 4096m | Memory allocation (4096m - 6144m recommended) |
| `SERVER_PORT` | 16261 | UDP port for game connections |
| `MODS` | _(empty)_ | Mod IDs (semicolon separated) |
| `WORKSHOP_ITEMS` | _(empty)_ | Workshop item IDs (semicolon separated) |

### Advanced Configuration

For detailed server settings, edit the server.ini file after first startup:
```bash
nano ./saves/Server/[SERVER_NAME].ini
```

See `config/server.ini.example` for all available options and documentation.

### Sandbox/Gameplay Settings

Customize zombie difficulty, loot, and survival settings:
```bash
nano ./saves/Server/[SERVER_NAME]_SandboxVars.lua
```

See `config/server_settings.ini.example` for common settings.

## 📂 Volume Structure

The container uses four persistent volumes:

```
./server/          # Server installation files (auto-populated)
./config/          # Configuration templates and examples
./saves/           # ⚠️ CRITICAL: World saves and player data
./logs/            # Server logs
```

**IMPORTANT**: Always backup the `./saves/` directory! This contains your world data.

## 🌐 Networking

### Required Ports

| Port | Protocol | Purpose | Required |
|------|----------|---------|----------|
| 16261 | UDP | Main game port | ✅ Yes |
| 16262 | TCP | Additional TCP | ✅ Yes |
| 8766 | UDP | Steam query | ⚠️ Recommended |
| 8767 | UDP | Steam port | ⚠️ Recommended |

### Port Forwarding (for Internet Access)

To make your server accessible from the internet:

1. **Log into your router's admin panel**
2. **Find Port Forwarding settings** (sometimes called "Virtual Server" or "NAT")
3. **Forward these ports** to your server's local IP:
   - Port 16261 UDP → Your Orange Pi IP
   - Port 16262 TCP → Your Orange Pi IP
   - Port 8766 UDP → Your Orange Pi IP (optional)
   - Port 8767 UDP → Your Orange Pi IP (optional)

4. **Find your public IP**: Visit https://whatismyipaddress.com
5. **Share with friends**: `[Your Public IP]:16261`

### LAN-Only Server

If hosting only for local network:
- No port forwarding needed
- Players connect using your local IP (e.g., 192.168.1.100:16261)
- Set `SERVER_PUBLIC=false` in `.env`

## 🔄 Updating the Server

### Automatic Updates
Set `AUTO_UPDATE=true` in `.env` (default). The server checks for updates on each restart.

### Manual Update
```bash
# Stop the server
docker-compose down

# Remove the container (keeps volumes)
docker-compose rm -f

# Rebuild and start
docker-compose up -d --build
```

### Force Update
```bash
# Enter the container
docker-compose exec zomboid-server bash

# Run update script
/home/steamcmd/update-server.sh
```

## 🎮 Admin Commands

### Accessing the Server Console

The server doesn't have an interactive console in Docker, but you can:

1. **Use RCON** (if configured in server.ini)
2. **Use in-game admin commands** (login as admin with your ADMIN_PASSWORD)
3. **View logs**: `docker-compose logs -f`

### Common In-Game Admin Commands

Once logged in as admin (username: `admin`, password: your `ADMIN_PASSWORD`):

- `/help` - List all commands
- `/players` - List connected players
- `/kickuser "username"` - Kick a player
- `/banuser "username"` - Ban a player
- `/adduser "username" "password"` - Add a user
- `/teleport "username" "x,y,z"` - Teleport player
- `/createhorde 100` - Create zombie horde
- `/godmode "username"` - Toggle god mode
- `/invisible "username"` - Toggle invisibility
- `/save` - Force save the world

## 🧩 Installing Mods

### Steam Workshop Mods

1. **Find mod Workshop IDs** on Steam Workshop
   - Example: `https://steamcommunity.com/sharedfiles/filedetails/?id=2169435993`
   - Workshop ID is `2169435993`

2. **Add to environment variables**
   ```bash
   # In .env file
   WORKSHOP_ITEMS=2169435993;2200148440;2432621382
   ```

3. **Also add to MODS** (get mod name from mod's info.txt)
   ```bash
   MODS=BetterSorting;MoreDescriptions;ImprovedUI
   ```

4. **Restart server**
   ```bash
   docker-compose restart
   ```

### Manual Mod Installation

1. **Download mod files** to `./server/mods/`
2. **Edit server.ini** to include mod names
3. **Restart server**

## 📊 Performance Tuning

### Memory Allocation

Orange Pi 5 Pro recommendations:
- **4GB RAM device**: `MEMORY=3072m` (leave 1GB for system)
- **8GB RAM device**: `MEMORY=4096m` or `MEMORY=6144m`
- **16GB RAM device**: `MEMORY=8192m`

### Box64 Optimization

The Dockerfile already includes optimized Box64 settings. For custom tuning, add to `.env`:
```bash
BOX64_DYNAREC_STRONGMEM=1
BOX64_DYNAREC_BIGBLOCK=1
BOX64_DYNAREC_SAFEFLAGS=0
BOX64_DYNAREC_FASTNAN=1
```

### Player Count Recommendations

- **Orange Pi 5 Pro (8GB)**: 16-24 players
- **Orange Pi 5 Pro (16GB)**: 24-32 players
- **Raspberry Pi 4 (8GB)**: 8-16 players

Higher player counts may cause lag on ARM64 due to emulation overhead.

### Reducing CPU Usage

1. Lower `MAX_PLAYERS`
2. Reduce `MEMORY` if too high
3. Disable unused features in server.ini:
   - `VoiceEnable=false`
   - `SteamVAC=false`

## 🔍 Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker-compose logs
```

**Common issues:**
- Insufficient memory → Reduce `MEMORY` setting
- Port already in use → Change `SERVER_PORT`
- Permission issues → Run with `sudo` or check Docker permissions

### Server Download Fails

**Issue:** SteamCMD fails to download server files

**Solutions:**
1. Check internet connection
2. Try again (temporary Steam issue)
3. Check if Steam servers are down
4. Ensure sufficient disk space

### Players Can't Connect

**LAN Connection:**
1. Verify server is running: `docker-compose ps`
2. Check local IP: `ip addr show`
3. Ensure firewall allows port 16261 UDP
4. Test with server IP:PORT in game

**Internet Connection:**
1. Verify port forwarding is configured
2. Test ports: https://www.yougetsignal.com/tools/open-ports/
3. Check public IP hasn't changed
4. Ensure `SERVER_PUBLIC=true` if using server browser

### Performance Issues

**Server is lagging:**
1. Check CPU/RAM usage in CasaOS or `docker stats`
2. Reduce `MAX_PLAYERS`
3. Reduce `MEMORY` if swapping occurs
4. Disable mods temporarily
5. Check for zombie hordes (can cause lag spikes)

**First startup is very slow:**
- This is normal! Box64 needs to compile code on first run
- Subsequent starts will be much faster
- Initial download takes 10-30 minutes

### Box64 Emulation Errors

**Check Box64 logs:**
```bash
docker-compose exec zomboid-server bash
box64 --version
```

**If Box64 isn't working:**
- Rebuild container: `docker-compose up -d --build`
- Check architecture: `uname -m` (should show `aarch64`)

### SteamCMD Authentication Issues

**Issue:** "Invalid Password" or authentication errors

**Solution:**
SteamCMD is used anonymously for dedicated servers. If you see auth errors:
1. This is usually temporary
2. Wait a few minutes and try again
3. Steam may be performing maintenance

### Server Crashes or Exits

**Check crash logs:**
```bash
docker-compose logs | grep -i error
cat ./logs/server.log
```

**Common causes:**
- Out of memory → Increase host RAM or reduce `MEMORY`
- Corrupted save → Restore from backup
- Incompatible mods → Remove recently added mods

## 💾 Backup and Restore

### Manual Backup

```bash
# Stop the server first
docker-compose down

# Backup saves directory
tar -czf zomboid-backup-$(date +%Y%m%d).tar.gz ./saves/

# Restart server
docker-compose up -d
```

### Automated Backups

Create a cron job:
```bash
# Edit crontab
crontab -e

# Add this line (backup daily at 3 AM)
0 3 * * * cd /path/to/Zomboid-Test && tar -czf ~/backups/zomboid-$(date +\%Y\%m\%d).tar.gz ./saves/
```

### Restore from Backup

```bash
# Stop the server
docker-compose down

# Restore saves
tar -xzf zomboid-backup-20241212.tar.gz

# Start server
docker-compose up -d
```

## 🛠️ Advanced Usage

### Building Custom Image

```bash
# Build with custom tag
docker build -t my-zomboid-server:latest .

# Update docker-compose.yml to use your image
# Then start
docker-compose up -d
```

### Multiple Server Instances

1. **Copy the directory**
   ```bash
   cp -r Zomboid-Test Zomboid-Test-2
   cd Zomboid-Test-2
   ```

2. **Edit `.env`**
   - Change `SERVER_NAME`
   - Change `SERVER_PORT` (e.g., 16271)

3. **Edit `docker-compose.yml`**
   - Change `container_name`
   - Update port mappings

4. **Start second instance**
   ```bash
   docker-compose up -d
   ```

### Resource Limits in CasaOS

In CasaOS UI or docker-compose.yml:
```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'
      memory: 6G
    reservations:
      cpus: '2.0'
      memory: 4G
```

### Viewing Real-Time Logs in CasaOS

1. Open CasaOS dashboard
2. Click on the Zomboid Server container
3. Click "Logs" tab
4. Logs update in real-time

## 📖 Additional Resources

- **Project Zomboid Wiki**: https://pzwiki.net/
- **Dedicated Server Guide**: https://pzwiki.net/wiki/Dedicated_Server
- **Steam Workshop**: https://steamcommunity.com/app/108600/workshop/
- **Box64 Project**: https://github.com/ptitSeb/box64
- **CasaOS Documentation**: https://casaos.io/

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on ARM64
5. Submit a pull request

## 📄 License

This project is provided as-is for running Project Zomboid dedicated servers. Project Zomboid is owned by The Indie Stone.

## ⚠️ Disclaimer

- This is a community project, not officially supported by The Indie Stone
- Performance on ARM64 may vary due to emulation
- Always backup your server data
- Use strong passwords for admin access

## 🙏 Credits

- **The Indie Stone** - Project Zomboid developers
- **ptitSeb** - Box64 and Box86 developer
- **Community contributors** - Testing and improvements

## 📞 Support

Having issues? 
1. Check the [Troubleshooting](#-troubleshooting) section
2. Review container logs: `docker-compose logs`
3. Open an issue on GitHub with:
   - Your device specs
   - Docker version
   - Error logs
   - Steps to reproduce

---

**Enjoy surviving the zombie apocalypse on your ARM64 device! 🧟‍♂️**
