#!/usr/bin/env bash
# Create a "Memory" sink in OpenSink and print the sink ID.
# Usage: ./init-memory-sink.sh
# Requires: OPENSINK_API_KEY

set -euo pipefail

: "${OPENSINK_API_KEY:?Set OPENSINK_API_KEY}"

BASE_URL="${OPENSINK_URL:-https://api.opensink.com}"

response=$(curl -sf -X POST "${BASE_URL}/sinks" \
  -H "Authorization: Bearer ${OPENSINK_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Memory",
    "description": "Durable agent memory store",
    "color": "purple"
  }')

sink_id=$(echo "$response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "✅ Memory sink created!"
echo "Sink ID: ${sink_id}"
echo ""
echo "Set this in your environment:"
echo "  export OPENSINK_SINK_ID=${sink_id}"
