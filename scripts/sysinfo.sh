#!/usr/bin/env bash
set -euo pipefail

echo "=== System Information Report ==="
echo "Current User: $(whoami) (UID: $EUID)"
echo "Hostname: $(hostname)"
echo "Kernel Release: $(uname -r)"
echo "System Date (ISO-8601): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "--- Disk Usage ---"
df -h / | awk 'NR==1 || NR==2'
echo "--- Memory Usage ---"
free -h
echo "--- Docker Daemon Status ---"
if systemctl is-active --quiet docker; then
    echo "Docker daemon is running."
else
    echo "Docker daemon is NOT running or systemctl is unavailable."
fi