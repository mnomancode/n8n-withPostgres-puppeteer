# n8n + PostgreSQL + Puppeteer Docker Stack

## Architecture Overview

This is a Docker Compose setup running n8n (workflow automation) with:
- **n8n service**: Custom-built container with Puppeteer support for browser automation
- **PostgreSQL**: Persistent data storage with two-tier user system (root + application user)
- **Key integration**: Puppeteer nodes pre-installed at `/opt/n8n-custom-nodes` for web scraping/automation workflows

### Service Dependencies
n8n depends on PostgreSQL health check before starting. Database initialization creates a non-root user (`POSTGRES_NON_ROOT_USER`) via `init-data.sh`, which n8n uses for connections (not the root `POSTGRES_USER`).

## Development Workflows

### Starting/Stopping Services
```bash
# Start (requires .env configuration first)
docker-compose up -d

# Stop
docker-compose stop

# View logs
docker-compose logs -f n8n
docker-compose logs -f postgres
```

### Configuration Changes
When modifying `.env` variables or `docker-compose.yml`:
```bash
docker-compose down          # Stop and remove containers
docker-compose up -d --build # Rebuild and restart
```

### Debugging Container Issues
```bash
# Check service health
docker-compose ps

# Exec into n8n container
docker-compose exec n8n sh

# Verify Puppeteer installation
docker-compose exec n8n cat /docker-custom-entrypoint.sh
```

## Critical Conventions

### Environment Variables (.env)
**Always update `.env` before first deployment** - contains database credentials with placeholder values:
- `POSTGRES_USER/POSTGRES_PASSWORD`: PostgreSQL root credentials
- `POSTGRES_NON_ROOT_USER/POSTGRES_NON_ROOT_PASSWORD`: Application-level credentials (used in `docker-compose.yml` for n8n's `DB_POSTGRESDB_USER/PASSWORD`)

### Custom Node Installation Pattern
Puppeteer nodes are installed system-wide in `/opt/n8n-custom-nodes` (not user's `.n8n` directory) because:
1. Survives volume mounts to `/home/node/.n8n`
2. Pre-installed at build time for consistency
3. Registered via `N8N_CUSTOM_EXTENSIONS` environment variable in `docker-custom-entrypoint.sh`

### Docker Image Customization
The `Dockerfile` extends `docker.n8n.io/n8nio/n8n:next` (Alpine Linux) with:
- Chromium browser (`/usr/bin/chromium-browser`) for Puppeteer
- Custom entrypoint wrapper (`docker-custom-entrypoint.sh`) that prints diagnostic info and configures custom nodes
- Ownership changes to ensure `node` user can access `/opt/n8n-custom-nodes`

### Puppeteer/Chromium Security Requirements
The n8n service requires special Docker capabilities to run Chromium:
- `cap_add: SYS_ADMIN` - Enables namespace operations for browser sandboxing
- `security_opt: seccomp:unconfined` - Allows system calls needed by Chromium
- `/dev/shm` mount - Provides shared memory for browser processes (prevents crashes)

These are required because Chromium's sandbox needs kernel-level permissions that are restricted by default in containers.

## Integration Points

### Webhook URL Configuration
`WEBHOOK_URL=https://noman.n8nu.com` in `docker-compose.yml` defines the public-facing URL for n8n webhooks. Update this when deploying to different domains.

### Volume Persistence
- `db_storage`: PostgreSQL data at `/var/lib/postgresql/data`
- `n8n_storage`: n8n workflows/credentials at `/home/node/.n8n`

Both are Docker-managed volumes (not bind mounts) - backup via `docker volume` commands.

### Port Exposure
n8n exposed on `5678:5678`. PostgreSQL internal only (no external port mapping).

## Adding New Custom Nodes

Modify `Dockerfile` to install additional n8n community nodes:
```dockerfile
RUN cd /opt/n8n-custom-nodes && \
    npm install n8n-nodes-puppeteer n8n-nodes-other-package
```
Then rebuild: `docker-compose up -d --build`
