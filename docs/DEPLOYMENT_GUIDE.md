# Deployment Guide - Hetzner Server with Caddy

## Overview

This guide covers deploying Dreamland PRO CRM to your Hetzner server (46.62.241.204) using Kamal 2, with Caddy handling SSL termination and reverse proxy.

## Architecture

```
Internet → Caddy (SSL) → Rails App Container (port 3000)
                       ↓
                    SQLite Volume
```

- **Domain:** pro.dreamland.kz
- **SSL:** Handled by Caddy (automatic Let's Encrypt)
- **Reverse Proxy:** Caddy → Rails container on port 3000
- **Database:** SQLite with persistent Docker volume

## Prerequisites

### 1. Local Machine

```bash
# Verify you have Kamal installed
kamal version

# If not installed:
gem install kamal
```

### 2. Docker Hub Registry

```bash
# Set your Docker Hub password as environment variable
export KAMAL_REGISTRY_PASSWORD="your_docker_hub_access_token"

# Or add to your shell profile (~/.zshrc or ~/.bashrc):
echo 'export KAMAL_REGISTRY_PASSWORD="your_docker_hub_access_token"' >> ~/.zshrc
source ~/.zshrc
```

### 3. Server Setup

SSH into your Hetzner server and verify:

```bash
ssh root@46.62.241.204

# Check Docker is running
docker ps

# Check Caddy is running
docker ps | grep caddy

# Check Caddy network exists
docker network ls | grep caddy

# If Caddy network doesn't exist, create it:
docker network create caddy
```

## Caddy Configuration

### Update Caddyfile

SSH into your server and update the Caddyfile:

```bash
ssh root@46.62.241.204
```

**Option 1: Reference Kamal container directly (Recommended)**

Update your Caddyfile to:

```caddyfile
pro.dreamland.kz {
    # Kamal creates containers named: dreamland_pro-web
    # Use the service name that Kamal creates
    reverse_proxy dreamland_pro-web:3000

    # Enable compression
    encode gzip

    # Add headers for security
    header {
        # Hide Caddy version
        -Server

        # Security headers
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
    }

    # Logging
    log {
        output file /var/log/caddy/dreamland_pro.log
    }
}
```

**Option 2: Use Docker network alias**

Alternatively, keep your current `rails:3000` reference and we'll add an alias during deployment.

### Reload Caddy

After updating the Caddyfile:

```bash
# If Caddy is running as Docker container
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# OR if running as system service
systemctl reload caddy
```

## First-Time Deployment

### 1. Setup Kamal on Server

From your local machine:

```bash
cd ~/Projects/dreamland-pro

# This will:
# - Install Docker if needed
# - Create necessary directories
# - Set up the environment
kamal setup
```

This will:
1. Build the Docker image locally
2. Push to Docker Hub
3. Pull image on server
4. Create volumes
5. Start containers
6. Run database migrations

### 2. Verify Deployment

```bash
# Check container is running
ssh root@46.62.241.204 "docker ps | grep dreamland_pro"

# Check logs
kamal app logs

# Access Rails console
kamal console

# Check database
kamal dbc
```

### 3. Test the Application

Open your browser:
```
https://pro.dreamland.kz
```

You should see the Dreamland PRO CRM login page.

## Regular Deployments

After making code changes:

```bash
# 1. Commit your changes
git add .
git commit -m "Your commit message"
git push

# 2. Deploy
kamal deploy

# This will:
# - Build new Docker image
# - Push to Docker Hub
# - Pull on server
# - Run migrations
# - Swap containers with zero downtime
```

## Common Commands

### Logs

```bash
# Tail logs
kamal app logs -f

# Last 100 lines
kamal app logs --lines 100

# Specific role
kamal app logs -r web
```

### Rails Console

```bash
# Interactive Rails console
kamal console

# Run a command
kamal app exec "bin/rails runner 'puts Client.count'"
```

### Database

```bash
# Rails database console
kamal dbc

# Run migrations
kamal app exec "bin/rails db:migrate"

# Seed data
kamal app exec "bin/rails db:seed"

# Check migration status
kamal app exec "bin/rails db:migrate:status"
```

### Container Management

```bash
# Restart application
kamal app restart

# Stop application
kamal app stop

# Start application
kamal app start

# Remove all containers and volumes (⚠️ DANGER: deletes data!)
kamal remove
```

### Server Access

```bash
# SSH into server
kamal app exec --interactive bash

# Short alias
kamal shell
```

## Database Backups

Since we're using SQLite, the database is in the Docker volume. Here's how to back it up:

### Manual Backup

```bash
# SSH into server
ssh root@46.62.241.204

# Copy database from volume to local server
docker run --rm \
  -v dreamland_pro_storage:/source \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/dreamland_pro_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /source .

# Download to local machine (from your laptop)
scp root@46.62.241.204:dreamland_pro_backup_*.tar.gz ./backups/
```

### Automated Backup Script

Create `/root/backup_dreamland.sh` on server:

```bash
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="dreamland_pro_${DATE}.tar.gz"

mkdir -p $BACKUP_DIR

docker run --rm \
  -v dreamland_pro_storage:/source \
  -v $BACKUP_DIR:/backup \
  ubuntu tar czf /backup/$FILENAME -C /source .

# Keep only last 7 days of backups
find $BACKUP_DIR -name "dreamland_pro_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $FILENAME"
```

Add to crontab:

```bash
chmod +x /root/backup_dreamland.sh
crontab -e

# Add line (daily at 2 AM):
0 2 * * * /root/backup_dreamland.sh >> /var/log/dreamland_backup.log 2>&1
```

## Rollback

If a deployment has issues:

```bash
# List recent deploys
kamal app images

# Rollback to previous version
kamal rollback [VERSION]

# Or just redeploy last working git commit
git checkout <previous-commit>
kamal deploy
git checkout main
```

## Environment Variables

Secrets are managed via `.kamal/secrets` file (not committed to git).

To update environment variables:

1. Edit `.kamal/secrets` locally
2. Run `kamal deploy` to apply changes

To add new secrets:

1. Add to `config/deploy.yml` under `env/secret`
2. Add extraction logic in `.kamal/secrets`
3. Deploy

## Monitoring

### Health Check

```bash
# Check if app is responding
curl -I https://pro.dreamland.kz

# Check container health
ssh root@46.62.241.204 "docker ps | grep dreamland_pro"
```

### Resource Usage

```bash
# Check container stats
ssh root@46.62.241.204 "docker stats --no-stream dreamland_pro-web"

# Check disk usage
ssh root@46.62.241.204 "df -h"

# Check volume size
ssh root@46.62.241.204 "docker system df -v | grep dreamland_pro_storage"
```

## Troubleshooting

### Container won't start

```bash
# Check logs
kamal app logs

# Check if migrations failed
kamal app exec "bin/rails db:migrate:status"

# Access container
kamal shell
```

### Caddy can't reach container

```bash
# Verify container is on caddy network
ssh root@46.62.241.204 "docker inspect dreamland_pro-web | grep caddy"

# Manually add to network if needed
ssh root@46.62.241.204 "docker network connect caddy dreamland_pro-web"

# Test connectivity from Caddy container
ssh root@46.62.241.204 "docker exec caddy curl http://dreamland_pro-web:3000/up"
```

### SSL Certificate Issues

```bash
# Check Caddy logs
ssh root@46.62.241.204 "docker logs caddy | tail -50"

# Verify DNS is pointing to server
nslookup pro.dreamland.kz

# Should resolve to: 46.62.241.204
```

### Database locked errors

SQLite can have issues with concurrent writes. Check:

```bash
# Check for long-running queries
kamal console
# In Rails console:
ActiveRecord::Base.connection.execute("PRAGMA busy_timeout = 5000")
```

### Out of disk space

```bash
# Check disk usage
ssh root@46.62.241.204 "df -h"

# Clean up old Docker images
ssh root@46.62.241.204 "docker image prune -a -f"

# Clean up old containers
ssh root@46.62.241.204 "docker container prune -f"
```

## Security Checklist

- [x] SSL enabled via Caddy (automatic Let's Encrypt)
- [x] RAILS_FORCE_SSL=true configured
- [x] Docker Hub uses access token (not password)
- [x] RAILS_MASTER_KEY kept secret (not in git)
- [x] Container runs as non-root user (UID 1000)
- [x] Caddy security headers configured
- [ ] Set up firewall rules (ufw)
- [ ] Configure automated backups
- [ ] Set up monitoring/alerts
- [ ] Review Rails credentials encryption

## Useful Aliases

Add to your shell profile (~/.zshrc or ~/.bashrc):

```bash
# Kamal shortcuts
alias kd='kamal deploy'
alias kl='kamal app logs -f'
alias kc='kamal console'
alias ks='kamal shell'
alias kr='kamal app restart'

# Quick server access
alias hetzner='ssh root@46.62.241.204'
```

## Next Steps

1. **Configure wazzup24 Webhook URL**
   ```
   https://pro.dreamland.kz/webhooks/wazzup24
   ```

2. **Set up monitoring** (optional)
   - Consider adding Uptime Kuma or similar
   - Set up log aggregation

3. **Configure backups**
   - Implement automated backup script
   - Test restore procedure

4. **Create admin user**
   ```bash
   kamal console
   # In Rails console:
   User.create!(email: 'admin@dreamland.kz', password: 'secure_password', role: :admin)
   ```

## Support

For issues:
1. Check logs: `kamal app logs`
2. Check container: `ssh root@46.62.241.204 "docker ps"`
3. Check Caddy: `ssh root@46.62.241.204 "docker logs caddy"`
4. Review this guide
5. Check Kamal docs: https://kamal-deploy.org

---

**Last Updated:** 2026-01-12
**Kamal Version:** 2.x
**Rails Version:** 8.1
**Server:** Hetzner (46.62.241.204)
**Domain:** pro.dreamland.kz
