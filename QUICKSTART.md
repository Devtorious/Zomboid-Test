# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- ARM64 device (Orange Pi, Raspberry Pi, etc.)
- Docker and Docker Compose installed
- 4GB+ RAM available
- 10GB free disk space

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Devtorious/Zomboid-Test.git
   cd Zomboid-Test
   ```

2. **Configure your server**
   ```bash
   cp .env.example .env
   nano .env  # Change ADMIN_PASSWORD at minimum!
   ```

3. **Start the server**
   ```bash
   docker-compose up -d
   ```

4. **Monitor first-time installation** (takes 10-30 minutes)
   ```bash
   docker-compose logs -f
   ```

5. **Connect to your server**
   - Open Project Zomboid
   - Join → Server Browser
   - Find your server or add manually with your IP:16261

### Important First Steps

⚠️ **Change the admin password** in `.env` from `changeme` to something secure!

🌐 **Port forwarding**: For internet access, forward UDP port 16261 to your device's local IP

📁 **Backup saves**: The `./saves/` directory contains your world - back it up regularly!

### Troubleshooting

**Server not appearing?**
- Check logs: `docker-compose logs`
- Verify it's running: `docker-compose ps`
- Ensure ports are forwarded

**First start is slow?**
- Normal! Box64 compiles code cache on first run
- Server download takes 10-30 minutes
- Subsequent starts are much faster

### Next Steps

- Read the full [README.md](README.md) for detailed configuration
- Check [config/server.ini.example](config/server.ini.example) for all options
- Visit the [Project Zomboid Wiki](https://pzwiki.net/) for gameplay help

---

**Need help?** Open an issue on GitHub with your error logs.
