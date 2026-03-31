#!/bin/bash
# TaskFlow Industrial Clean Setup Script
set -e

echo "--- INITIALIZING TERMINAL CLEANUP ---"

# Remove build artifacts and cache
echo "Purging .next and build logs..."
rm -rf .next
rm -f build_log.txt build_error.log

# Force reinstall if requested
if [ "$1" == "--force" ]; then
    echo "CRITICAL: Purging node_modules..."
    rm -rf node_modules
    rm -f package-lock.json
    echo "Reinstalling dependencies..."
    npm install
fi

echo "Verifying environment configuration..."
if [ ! -f .env.local ]; then
    echo "WARNING: .env.local missing. System may fail at runtime."
else
    echo "Config: NOMINAL"
fi

echo "--- CLEANUP COMPLETE. RUN 'npm run build' TO VERIFY BINARY ---"
