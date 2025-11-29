#!/bin/sh

print_banner() {
    echo "=========================================="
    echo "  n8n with Puppeteer - Startup Info"
    echo "=========================================="
    echo "Node.js version: $(node -v)"
    echo "n8n version: $(n8n --version)"
    
    # Check Chromium installation
    CHROME_VERSION=$("$PUPPETEER_EXECUTABLE_PATH" --version 2>/dev/null || echo "Chromium not found")
    echo "Chromium version: $CHROME_VERSION"
    
    # Check Puppeteer node installation
    PUPPETEER_PATH="/opt/n8n-custom-nodes/node_modules/n8n-nodes-puppeteer"
    if [ -f "$PUPPETEER_PATH/package.json" ]; then
        PUPPETEER_VERSION=$(node -p "require('$PUPPETEER_PATH/package.json').version")
        echo "n8n-nodes-puppeteer: v$PUPPETEER_VERSION"
        
        # Check core puppeteer version
        CORE_PUPPETEER_VERSION=$(cd "$PUPPETEER_PATH" && node -e "try { const version = require('puppeteer/package.json').version; console.log(version); } catch(e) { console.log('not found'); }")
        echo "Puppeteer core: v$CORE_PUPPETEER_VERSION"
    else
        echo "n8n-nodes-puppeteer: NOT INSTALLED"
    fi
    
    echo "Puppeteer executable: $PUPPETEER_EXECUTABLE_PATH"
    echo "Custom nodes path: /opt/n8n-custom-nodes"
    echo "=========================================="
}

# Configure custom nodes path
if [ -n "$N8N_CUSTOM_EXTENSIONS" ]; then
    export N8N_CUSTOM_EXTENSIONS="/opt/n8n-custom-nodes:${N8N_CUSTOM_EXTENSIONS}"
else
    export N8N_CUSTOM_EXTENSIONS="/opt/n8n-custom-nodes"
fi

# Display startup banner
print_banner

# Start n8n using original entrypoint
exec /docker-entrypoint.sh "$@"