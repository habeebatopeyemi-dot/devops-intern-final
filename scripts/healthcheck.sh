#!/usr/bin/env bash
set -euo pipefail

TARGET_URL="${1:-http://localhost:8080}"

echo "Checking health of target: $TARGET_URL"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL/healthz" || echo "000")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "SUCCESS: Endpoint /healthz returned HTTP 200."
    exit 0
else
    echo "FAILURE: Endpoint /healthz returned HTTP status: $HTTP_STATUS"
    exit 1
fi