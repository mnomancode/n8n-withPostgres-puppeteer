# Cloudflare Tunnel Setup Instructions for Mac

Complete guide to set up Cloudflare Tunnel from scratch on macOS.

---

## Step 1: Remove Existing Cloudflare Tunnel Setup

Clean up any existing cloudflared installations and configurations:

```bash
# Stop and unload any running cloudflared service
sudo launchctl unload /Library/LaunchDaemons/com.cloudflare.cloudflared.plist 2>/dev/null
launchctl unload ~/Library/LaunchAgents/com.cloudflare.cloudflared.plist 2>/dev/null

# Remove the service files
sudo rm /Library/LaunchDaemons/com.cloudflare.cloudflared.plist 2>/dev/null
rm ~/Library/LaunchAgents/com.cloudflare.cloudflared.plist 2>/dev/null

# Remove cloudflared directory and configs
rm -rf ~/.cloudflared/

# Uninstall cloudflared if installed via Homebrew
brew uninstall cloudflared 2>/dev/null

# Or remove the binary if installed manually
sudo rm /usr/local/bin/cloudflared 2>/dev/null
```

---

## Step 2: Install Cloudflare Tunnel (cloudflared)

```bash
# Install via Homebrew (recommended)
brew install cloudflare/cloudflare/cloudflared

# Verify installation
cloudflared --version
```

---

## Step 3: Authenticate with Cloudflare

```bash
# Login to Cloudflare (this will open a browser)
cloudflared tunnel login
```

This will create a certificate file at `~/.cloudflared/cert.pem`

---

## Step 4: Create the Tunnel

```bash
# Create a new tunnel named "n8nNoman"
cloudflared tunnel create n8nNoman
```

This will:
- Create a tunnel with a UUID
- Save credentials to `~/.cloudflared/<UUID>.json`
- Display the tunnel UUID (save this!)

**Example output:**
```
Tunnel credentials written to /Users/muhammadnoman/.cloudflared/b03d38d7-ff18-4126-bf7d-9ac69ae750ae.json
Created tunnel n8nNoman with id b03d38d7-ff18-4126-bf7d-9ac69ae750ae
```

---

## Step 5: Create the Configuration File

```bash
# Create the config file
nano ~/.cloudflared/config.yml
```

Add this content (replace `<UUID>` with your actual tunnel UUID from Step 4):

```yaml
tunnel: n8nNoman
credentials-file: /Users/muhammadnoman/.cloudflared/<UUID>.json

ingress:
  - hostname: n8n.n8nu.com
    service: http://localhost:5678
  - service: http_status:404
```

**Example with actual UUID:**
```yaml
tunnel: n8nNoman
credentials-file: /Users/muhammadnoman/.cloudflared/b03d38d7-ff18-4126-bf7d-9ac69ae750ae.json

ingress:
  - hostname: n8n.n8nu.com
    service: http://localhost:5678
  - service: http_status:404
```

Save and exit (Ctrl+O, Enter, Ctrl+X in nano)

---

## Step 6: Create DNS Record

```bash
# Route your domain to the tunnel
cloudflared tunnel route dns n8nNoman n8n.n8nu.com
```

---

## Step 7: Create the LaunchDaemon Service File

Create the proper service configuration:

```bash
# Create/edit the plist file
sudo nano /Library/LaunchDaemons/com.cloudflare.cloudflared.plist
```

Add this content (replace `muhammadnoman` with your actual username):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Label</key>
<string>com.cloudflare.cloudflared</string>
<key>ProgramArguments</key>
<array>
<string>/opt/homebrew/bin/cloudflared</string>
<string>tunnel</string>
<string>--config</string>
<string>/Users/muhammadnoman/.cloudflared/config.yml</string>
<string>run</string>
<string>n8nNoman</string>
</array>
<key>RunAtLoad</key>
<true/>
<key>StandardOutPath</key>
<string>/Library/Logs/com.cloudflare.cloudflared.out.log</string>
<key>StandardErrorPath</key>
<string>/Library/Logs/com.cloudflare.cloudflared.err.log</string>
<key>KeepAlive</key>
<dict>
<key>SuccessfulExit</key>
<false/>
</dict>
<key>ThrottleInterval</key>
<integer>5</integer>
</dict>
</plist>
```

Save and exit (Ctrl+O, Enter, Ctrl+X)

---

## Step 8: Load and Start the Service

```bash
# Load the service
sudo launchctl load /Library/LaunchDaemons/com.cloudflare.cloudflared.plist

# Start the service
sudo launchctl start com.cloudflare.cloudflared

# Wait a few seconds for it to connect
sleep 5

# Check tunnel status
cloudflared tunnel info n8nNoman
```

You should see output showing active connections!

---

## Useful Management Commands

### Check Tunnel Status

```bash
# List all tunnels
cloudflared tunnel list

# Get info about specific tunnel
cloudflared tunnel info n8nNoman

# Check if cloudflared process is running
ps aux | grep cloudflared

# Check launchd service status
sudo launchctl list | grep cloudflared
```

### View Logs

```bash
# View output logs
tail -f /Library/Logs/com.cloudflare.cloudflared.out.log

# View error logs
tail -f /Library/Logs/com.cloudflare.cloudflared.err.log

# View last 50 lines
tail -50 /Library/Logs/com.cloudflare.cloudflared.err.log

# View system logs
log show --predicate 'process == "cloudflared"' --last 5m
```

### Start/Stop/Restart Service

```bash
# Stop the service
sudo launchctl stop com.cloudflare.cloudflared

# Start the service
sudo launchctl start com.cloudflare.cloudflared

# Restart (stop then start)
sudo launchctl stop com.cloudflare.cloudflared
sudo launchctl start com.cloudflare.cloudflared

# Unload service (stops and removes from launchd)
sudo launchctl unload /Library/LaunchDaemons/com.cloudflare.cloudflared.plist

# Reload service (after making changes to plist)
sudo launchctl unload /Library/LaunchDaemons/com.cloudflare.cloudflared.plist
sudo launchctl load /Library/LaunchDaemons/com.cloudflare.cloudflared.plist
```

---

## Troubleshooting

### Service Won't Start

If the service doesn't start, try running it manually first to see errors:

```bash
cloudflared tunnel run n8nNoman
```

This will show real-time errors and help identify the problem.

### Common Issues

1. **Config file path issue** - Verify the UUID matches:
   ```bash
   cat ~/.cloudflared/config.yml
   ls -la ~/.cloudflared/
   ```

2. **Credentials file missing**:
   ```bash
   ls -la ~/.cloudflared/*.json
   ```

3. **n8n not running** - Make sure your n8n service is running on port 5678:
   ```bash
   lsof -i :5678
   ```

4. **Wrong cloudflared path** - If installed elsewhere:
   ```bash
   which cloudflared
   ```
   Update the path in the plist file if different from `/opt/homebrew/bin/cloudflared`

### Verify Configuration

```bash
# Check if config is valid
cat ~/.cloudflared/config.yml

# Verify credentials file exists
ls -la ~/.cloudflared/b03d38d7-ff18-4126-bf7d-9ac69ae750ae.json

# Check plist configuration
sudo cat /Library/LaunchDaemons/com.cloudflare.cloudflared.plist
```

---

## Complete Uninstall (If Needed)

To completely remove cloudflared:

```bash
# Stop and unload service
sudo launchctl unload /Library/LaunchDaemons/com.cloudflare.cloudflared.plist

# Remove service file
sudo rm /Library/LaunchDaemons/com.cloudflare.cloudflared.plist

# Remove configuration directory
rm -rf ~/.cloudflared/

# Uninstall via Homebrew
brew uninstall cloudflared

# Remove logs
sudo rm /Library/Logs/com.cloudflare.cloudflared.*
```

---

## Notes

- The tunnel will automatically start on system boot (RunAtLoad is set to true)
- The service will automatically restart if it crashes (KeepAlive is configured)
- Logs are stored in `/Library/Logs/`
- Make sure your n8n instance is running on `http://localhost:5678` before the tunnel will work
- The domain `n8n.n8nu.com` must be in a Cloudflare zone you control

---

## Quick Reference

**Your Tunnel Details:**
- Tunnel Name: `n8nNoman`
- Tunnel UUID: `b03d38d7-ff18-4126-bf7d-9ac69ae750ae`
- Domain: `n8n.n8nu.com`
- Local Service: `http://localhost:5678`
- Config File: `~/.cloudflared/config.yml`
- Credentials: `~/.cloudflared/b03d38d7-ff18-4126-bf7d-9ac69ae750ae.json`