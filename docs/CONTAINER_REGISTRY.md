# GitHub Container Registry Documentation

This document explains how to use the GitHub Container Registry (ghcr.io) for the Project Zomboid ARM64 Server Docker images.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Pulling Images](#pulling-images)
- [Available Tags](#available-tags)
- [Authentication](#authentication)
- [Using with Docker Compose](#using-with-docker-compose)
- [Using with CasaOS](#using-with-casaos)
- [Building Locally vs Using Registry](#building-locally-vs-using-registry)
- [For Maintainers](#for-maintainers)
- [For Contributors](#for-contributors)
- [Troubleshooting](#troubleshooting)

## Overview

### What is GitHub Container Registry?

GitHub Container Registry (ghcr.io) is GitHub's container registry service that allows us to:
- Store and distribute Docker images
- Automatically build images on code changes
- Version images with tags
- Provide easy access to pre-built images

### Why Use It for This Project?

**Benefits:**
- ⚡ **Faster deployment** - No need to build locally (saves 10-30+ minutes)
- 🔄 **Automatic updates** - Images built automatically on each release
- 📦 **Multi-architecture** - ARM64 and AMD64 images available
- 🎯 **Consistent builds** - Same image for all users
- 💾 **Reduced bandwidth** - Download once, use many times
- ✅ **Tested images** - Images are tested before release

### Registry URL

All images are available at:
```
ghcr.io/devtorious/zomboid-test
```

## Quick Start

### Pull and Run

```bash
# Pull the latest image
docker pull ghcr.io/devtorious/zomboid-test:latest

# Run the container
docker run -d \
  --name zomboid-server \
  -p 16261:16261/udp \
  -p 16262:16262/tcp \
  -p 8766:8766/udp \
  -p 8767:8767/udp \
  -v ./server:/home/steamcmd/server \
  -v ./config:/home/steamcmd/config \
  -v ./saves:/home/steamcmd/Zomboid \
  -v ./logs:/home/steamcmd/logs \
  ghcr.io/devtorious/zomboid-test:latest
```

### Using Docker Compose (Recommended)

See [Using with Docker Compose](#using-with-docker-compose) section below.

## Pulling Images

### Latest Version (Main Branch)

```bash
docker pull ghcr.io/devtorious/zomboid-test:latest
```

### Specific Version Release

```bash
# Pull version 1.0.0
docker pull ghcr.io/devtorious/zomboid-test:v1.0.0

# Pull version 1.2.3
docker pull ghcr.io/devtorious/zomboid-test:v1.2.3
```

### Specific Branch

```bash
# Pull latest from main branch
docker pull ghcr.io/devtorious/zomboid-test:main

# Pull latest from develop branch
docker pull ghcr.io/devtorious/zomboid-test:develop
```

### Specific Commit

```bash
# Pull specific commit from main branch
docker pull ghcr.io/devtorious/zomboid-test:main-abc1234
```

### Check Available Tags

Visit the package page:
https://github.com/Devtorious/Zomboid-Test/pkgs/container/zomboid-test

## Available Tags

| Tag Pattern | Description | Example | Update Frequency |
|------------|-------------|---------|------------------|
| `latest` | Latest stable release from main branch | `latest` | On every push to main |
| `v*.*.*` | Specific version release | `v1.0.0`, `v1.2.3` | On version tag push |
| `v*.*` | Major.minor version | `v1.0`, `v1.2` | On version tag push |
| `v*` | Major version only | `v1` | On version tag push |
| `main` | Latest build from main branch | `main` | On every push to main |
| `develop` | Latest build from develop branch | `develop` | On every push to develop |
| `main-<sha>` | Specific commit from main | `main-abc1234` | On commit push |

### Choosing the Right Tag

**For Production:**
- Use `v1.0.0` style tags for specific versions
- Use `latest` for automatic updates to stable releases

**For Testing/Development:**
- Use `main` for latest development build
- Use `develop` for bleeding-edge features
- Use `main-<sha>` for specific commit testing

**For CasaOS:**
- Use `latest` for most users (automatic updates)
- Use specific version tags if you need stability

## Authentication

### Public Images (No Authentication Required)

All images in this repository are public by default. You can pull them without authentication:

```bash
docker pull ghcr.io/devtorious/zomboid-test:latest
```

### Private Images (If Repository is Private)

If the repository is private, you need to authenticate:

#### 1. Create a Personal Access Token (PAT)

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Docker Registry Access")
4. Select scopes:
   - ✅ `read:packages` (to pull images)
   - ✅ `write:packages` (if you need to push)
5. Click "Generate token" and save it securely

#### 2. Login to Registry

```bash
# Using environment variable
export GITHUB_TOKEN=ghp_your_token_here
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin

# Or input directly
docker login ghcr.io -u YOUR_GITHUB_USERNAME
# Enter your PAT when prompted for password
```

#### 3. Pull Images

```bash
docker pull ghcr.io/devtorious/zomboid-test:latest
```

#### 4. Logout (Optional)

```bash
docker logout ghcr.io
```

## Using with Docker Compose

### Default Configuration (Using Registry)

The included `docker-compose.yml` is pre-configured to use the registry image:

```yaml
version: "3.8"

services:
  zomboid-server:
    # Uses pre-built image from GitHub Container Registry
    image: ghcr.io/devtorious/zomboid-test:latest
    
    # ... rest of configuration
```

**To use:**
```bash
# Pull latest image and start
docker-compose pull
docker-compose up -d

# View logs
docker-compose logs -f
```

### Using a Specific Version

Edit `docker-compose.yml`:

```yaml
services:
  zomboid-server:
    image: ghcr.io/devtorious/zomboid-test:v1.0.0  # Specific version
    # ... rest of configuration
```

### Building Locally Instead

If you want to build locally instead of using the registry:

```yaml
services:
  zomboid-server:
    # Comment out the image line
    # image: ghcr.io/devtorious/zomboid-test:latest
    
    # Uncomment the build section
    build:
      context: .
      dockerfile: Dockerfile
    
    # ... rest of configuration
```

### Updating to Latest Image

```bash
# Pull latest image
docker-compose pull

# Recreate container with new image
docker-compose up -d

# Remove old image (optional)
docker image prune -f
```

## Using with CasaOS

### Method 1: Import Docker Compose

1. **In CasaOS Dashboard:**
   - Go to App Store
   - Click "Import" or "Custom Install"
   - Select "Docker Compose"

2. **Upload or Paste:**
   - Upload the `docker-compose.yml` file, OR
   - Paste the docker-compose configuration

3. **Configure:**
   - Review and edit environment variables
   - Adjust port mappings if needed
   - Set up volume paths

4. **Install:**
   - Click "Install" or "Create"
   - Wait for image to be pulled
   - CasaOS will show the app in your dashboard

### Method 2: Manual App Creation

1. **In CasaOS Dashboard:**
   - Go to App Store
   - Click "Custom Install"

2. **Configure Container:**
   - **Image:** `ghcr.io/devtorious/zomboid-test:latest`
   - **Name:** `zomboid-server`
   - **Network Mode:** Bridge
   - **Restart Policy:** Unless stopped

3. **Add Ports:**
   - `16261` UDP → Host port `16261` (Main game port)
   - `16262` TCP → Host port `16262` (Additional TCP)
   - `8766` UDP → Host port `8766` (Steam query)
   - `8767` UDP → Host port `8767` (Steam port)

4. **Add Volumes:**
   - `/home/steamcmd/server` → `./server` (Server files)
   - `/home/steamcmd/config` → `./config` (Configuration)
   - `/home/steamcmd/Zomboid` → `./saves` (Save data)
   - `/home/steamcmd/logs` → `./logs` (Logs)

5. **Add Environment Variables:**
   - `SERVER_NAME` → `My Project Zomboid Server`
   - `ADMIN_PASSWORD` → `your_secure_password`
   - `MAX_PLAYERS` → `16`
   - `AUTO_UPDATE` → `true`
   - (Add others as needed)

6. **Create and Start**

### Updating in CasaOS

#### Automatic Updates (Watchtower)

Install Watchtower in CasaOS to automatically update containers:

```yaml
version: "3"
services:
  watchtower:
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_POLL_INTERVAL=86400  # Check daily
```

#### Manual Update

1. In CasaOS dashboard, find the Zomboid Server app
2. Click "Update" or "Recreate"
3. CasaOS will pull the latest image and restart

OR use command line:
```bash
docker pull ghcr.io/devtorious/zomboid-test:latest
docker-compose up -d
```

## Building Locally vs Using Registry

### When to Use Registry (Recommended)

✅ **Use the registry when:**
- You want quick deployment
- You're on slow internet (build uses less bandwidth than source + deps)
- You trust the automated builds
- You want tested, stable images
- You're deploying to multiple machines
- You're using CasaOS (easier updates)

**Advantages:**
- No build time (10-30+ minutes saved)
- Consistent images across deployments
- Automatic security updates
- Pre-tested builds
- Smaller download size (compared to building)

### When to Build Locally

✅ **Build locally when:**
- You've made custom modifications to Dockerfile
- You're developing or testing changes
- You want to verify the build process
- You're contributing to the project
- You need a specific Box64/Box86 version

**Advantages:**
- Full control over build process
- Can customize Dockerfile
- Can verify source code
- Useful for development

### Resource Comparison

| Aspect | Registry | Local Build |
|--------|----------|-------------|
| Time | ~2-5 minutes | ~15-40 minutes |
| Bandwidth | ~500MB-1GB | ~2-3GB |
| Disk Space | ~1.5GB | ~3GB (with build cache) |
| CPU Usage | Low (just pull) | High (compilation) |
| Reliability | High | Depends on hardware |

## For Maintainers

### Repository Setup

1. **Enable GitHub Container Registry**
   - Already enabled by default for all repositories
   - No special setup required

2. **Workflow Permissions**
   - Go to: Repository Settings → Actions → General
   - Under "Workflow permissions":
     - ✅ Select "Read and write permissions"
     - ✅ Check "Allow GitHub Actions to create and approve pull requests"
   - Click "Save"

3. **First Workflow Run**
   - Push a commit to `main` branch
   - Workflow will automatically run
   - Image will be pushed to ghcr.io

4. **Link Package to Repository**
   - After first push, go to repository's "Packages" section
   - Click on the package
   - Click "Connect to repository" if not automatic
   - Select this repository

5. **Set Package Visibility**
   - In package settings, under "Danger Zone"
   - Change visibility to "Public" (if desired)
   - Public packages can be pulled without authentication

### Creating a Release

```bash
# Tag a new version
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# GitHub Actions will automatically:
# 1. Build the Docker image
# 2. Push with version tags (v1.0.0, v1.0, v1, latest)
# 3. Create a GitHub Release with pull instructions
```

### Managing Package Settings

1. **Package Permissions**
   - Go to package settings
   - Manage who can read/write to the package
   - Add collaborators if needed

2. **Package Retention**
   - Set cleanup policies for old images
   - Keep specific tags (like `latest`, version tags)
   - Remove untagged images after X days

3. **Package Visibility**
   - Public: Anyone can pull (recommended)
   - Private: Requires authentication
   - Internal: Organization members only

## For Contributors

### How Images Are Built

1. **On Push to Main/Develop:**
   - Workflow: `.github/workflows/docker-build-push.yml`
   - Triggers on every push to main or develop branch
   - Builds for ARM64 and AMD64
   - Tags: `latest` (if main), `main`, `develop`, `main-<sha>`

2. **On Version Tag:**
   - Workflow: `.github/workflows/docker-release.yml`
   - Triggers on tags matching `v*.*.*`
   - Builds for ARM64 and AMD64
   - Tags: `v1.0.0`, `v1.0`, `v1`, `latest`
   - Creates GitHub Release

3. **On Pull Request:**
   - Workflow: `.github/workflows/docker-pr-build.yml`
   - Tests that the Dockerfile builds successfully
   - Does NOT push to registry
   - Comments on PR with build status

### Testing Docker Changes in PRs

When you modify Docker-related files:
1. Create a pull request
2. PR build workflow automatically runs
3. Check for build success/failure in PR checks
4. Build errors will be commented on the PR

### Local Testing Before PR

```bash
# Test build locally
docker build -t zomboid-test:local .

# Test multi-arch build (requires buildx)
docker buildx build --platform linux/arm64,linux/amd64 -t zomboid-test:local .
```

## Troubleshooting

### Authentication Issues

**Problem:** `Error response from daemon: pull access denied`

**Solutions:**
1. Check if package is public (should be)
2. If private, login with PAT: `docker login ghcr.io`
3. Verify PAT has `read:packages` scope
4. Check package permissions in GitHub

### Pull Rate Limits

**Problem:** Rate limit exceeded

**Solutions:**
- GitHub Container Registry has generous limits
- Authenticated pulls have higher limits
- Login with `docker login ghcr.io` if hitting limits

### Platform Mismatches

**Problem:** `WARNING: The requested image's platform (linux/arm64) does not match the detected host platform`

**This is usually OK:**
- Happens when pulling ARM64 image on AMD64 machine (or vice versa)
- Docker will use the correct architecture automatically
- For development, you might want the AMD64 image

**Force specific platform:**
```bash
# Force ARM64
docker pull --platform linux/arm64 ghcr.io/devtorious/zomboid-test:latest

# Force AMD64
docker pull --platform linux/amd64 ghcr.io/devtorious/zomboid-test:latest
```

### Image Not Found

**Problem:** `Error: manifest for ghcr.io/devtorious/zomboid-test:TAG not found`

**Solutions:**
1. Check tag exists: https://github.com/Devtorious/Zomboid-Test/pkgs/container/zomboid-test
2. Verify spelling of tag
3. Wait for workflow to finish (check Actions tab)
4. Check if workflow succeeded

### Slow Pull Speeds

**Solutions:**
1. Use a closer Docker registry mirror (if available)
2. Ensure stable internet connection
3. Try at different time of day
4. Check GitHub status: https://www.githubstatus.com

### Cache Issues

**Problem:** Old image still being used

**Solutions:**
```bash
# Force pull latest
docker-compose pull

# Remove old images
docker image prune -a

# Recreate container
docker-compose up -d --force-recreate
```

### Build Failures in Actions

**Problem:** Workflow fails to build image

**Check:**
1. View workflow logs in Actions tab
2. Common issues:
   - Dockerfile syntax errors
   - Missing dependencies
   - Network issues downloading packages
   - Permissions issues

**Solutions:**
1. Test build locally first
2. Fix errors in Dockerfile
3. Re-run failed workflow
4. Check Actions logs for details

### Package Visibility

**Problem:** Can't pull public package

**Solutions:**
1. Check package settings → Visibility
2. Ensure "Public" is selected
3. May take a few minutes to propagate
4. Try clearing Docker cache: `docker system prune -a`

## Additional Resources

- **GitHub Container Registry Docs:** https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
- **Docker Documentation:** https://docs.docker.com/
- **GitHub Actions:** https://docs.github.com/en/actions
- **Main README:** [../README.md](../README.md)
- **Contributing Guide:** [../CONTRIBUTING.md](../CONTRIBUTING.md)

---

**Questions or Issues?**

Open an issue on GitHub or check existing issues for solutions.
