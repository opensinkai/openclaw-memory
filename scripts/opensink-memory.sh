#!/usr/bin/env bash
# OpenSink Memory CLI — push, list, search, get memories
# Usage:
#   opensink-memory.sh push <title> [type] [body] [tags]
#   opensink-memory.sh list [--type TYPE] [--limit N]
#   opensink-memory.sh search <query> [--limit N]
#   opensink-memory.sh get <item-id>
#
# Requires: OPENSINK_API_KEY, OPENSINK_SINK_ID

set -euo pipefail

: "${OPENSINK_API_KEY:?Set OPENSINK_API_KEY}"
: "${OPENSINK_SINK_ID:?Set OPENSINK_SINK_ID}"

BASE_URL="${OPENSINK_URL:-https://api.opensink.com}"
AUTH="Authorization: Bearer ${OPENSINK_API_KEY}"
CT="Content-Type: application/json"

cmd="${1:?Usage: opensink-memory.sh <push|list|search|get> ...}"
shift

case "$cmd" in
  push)
    title="${1:?push requires a title}"
    type="${2:-note}"
    body="${3:-}"
    tags="${4:-}"
    
    # Build fields JSON
    fields="{}"
    if [ -n "$tags" ]; then
      # Convert comma-separated tags to JSON array
      tags_json=$(echo "$tags" | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
      fields="{\"tags\":${tags_json}}"
    fi

    occurred_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    payload=$(cat <<EOF
{
  "sink_id": "${OPENSINK_SINK_ID}",
  "title": $(printf '%s' "$title" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'),
  "body": $(printf '%s' "$body" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'),
  "type": "${type}",
  "fields": ${fields},
  "occurred_at": "${occurred_at}"
}
EOF
)

    response=$(curl -sf -X POST "${BASE_URL}/sink-items" \
      -H "$AUTH" -H "$CT" \
      -d "$payload")

    item_id=$(echo "$response" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['id'])" 2>/dev/null || echo "unknown")
    echo "✅ Memory saved (id: ${item_id})"
    echo "   ${title}"
    ;;

  list)
    type_filter=""
    limit=20
    while [ $# -gt 0 ]; do
      case "$1" in
        --type) type_filter="$2"; shift 2 ;;
        --limit) limit="$2"; shift 2 ;;
        *) shift ;;
      esac
    done

    url="${BASE_URL}/sink-items?sink_id=${OPENSINK_SINK_ID}&\$limit=${limit}"

    response=$(curl -sf -X GET "$url" -H "$AUTH")

    # Pretty print with python
    echo "$response" | python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
items = data.get('items', [])
type_filter = '${type_filter}'
for item in items:
    if type_filter and item.get('type') != type_filter:
        continue
    t = item.get('type', '-')
    title = item.get('title', '')
    ts = item.get('occurred_at', item.get('created_at', ''))[:16]
    iid = item.get('id', '')[:8]
    print(f'[{t}] {title}  ({ts}, id:{iid}…)')
if not items:
    print('No memories found.')
"
    ;;

  search)
    query="${1:?search requires a query}"
    limit="${2:-20}"

    # Fetch items and filter client-side (OpenSink doesn't have server-side search on items yet)
    url="${BASE_URL}/sink-items?sink_id=${OPENSINK_SINK_ID}&\$limit=50"
    response=$(curl -sf -X GET "$url" -H "$AUTH")

    echo "$response" | python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
items = data.get('items', [])
query = '${query}'.lower()
limit = int('${limit}')
matches = []
for item in items:
    text = (item.get('title','') + ' ' + (item.get('body','') or '') + ' ' + str(item.get('fields',{}))).lower()
    if query in text or any(w in text for w in query.split()):
        matches.append(item)
for item in matches[:limit]:
    t = item.get('type', '-')
    title = item.get('title', '')
    body = item.get('body', '')
    ts = item.get('occurred_at', item.get('created_at', ''))[:16]
    iid = item.get('id', '')[:8]
    print(f'[{t}] {title}  ({ts}, id:{iid}…)')
    if body:
        print(f'       {body[:100]}')
if not matches:
    print('No memories match that query.')
"
    ;;

  get)
    item_id="${1:?get requires an item ID}"
    response=$(curl -sf -X GET "${BASE_URL}/sink-items/${item_id}" -H "$AUTH")
    echo "$response" | python3 -c "
import sys, json
item = json.loads(sys.stdin.read())
print(f\"Title:  {item.get('title', '')}\")
print(f\"Type:   {item.get('type', '-')}\")
print(f\"Body:   {item.get('body', '') or '(none)'}\")
print(f\"Fields: {json.dumps(item.get('fields', {}))}\")
print(f\"Date:   {item.get('occurred_at', item.get('created_at', ''))}\")
print(f\"ID:     {item.get('id', '')}\")
"
    ;;

  *)
    echo "Unknown command: $cmd"
    echo "Usage: opensink-memory.sh <push|list|search|get>"
    exit 1
    ;;
esac
