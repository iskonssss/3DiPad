#!/usr/bin/env bash
# 3DiPad booth — same as "Start Booth.cmd" but for macOS and Linux.
#   ./start-booth.sh
set -u
cd "$(dirname "$0")"

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is not installed. Get it from https://nodejs.org (the LTS version)."
  exit 1
fi

echo "Updating to the latest version..."
git pull origin main || echo "  (no update — carrying on with the version already here)"

[ -d node_modules ] || { echo "Installing what the booth needs..."; npm install --no-audit --no-fund; }

echo "Building the tablet app..."
npm run build

(sleep 2 && (open http://localhost:3000/dashboard/ 2>/dev/null || xdg-open http://localhost:3000/dashboard/ 2>/dev/null)) &

echo
echo "Leave this window open. Press Ctrl-C to stop the booth."
echo
exec npm start
