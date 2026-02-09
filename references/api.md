# OpenSink API Reference (Memory-relevant subset)

Base URL: `https://api.opensink.com`
Auth: `Authorization: Bearer <OPENSINK_API_KEY>`

## Sinks

### Create Sink
`POST /sinks` — `{ name, description?, color?, is_public? }`

### List Sinks
`GET /sinks` → `{ items: [{ id, name, description, color, ... }], trail? }`

## Sink Items

### Create Item
`POST /sink-items`
```json
{
  "sink_id": "uuid",
  "title": "string (required, 1-255)",
  "body": "string | null",
  "type": "string | null (max 255)",
  "url": "string | null (max 2048)",
  "fields": {},
  "occurred_at": "ISO 8601 | null"
}
```

### Bulk Create
`POST /sink-items/bulk` — array of items

### List Items
`GET /sink-items?sink_id=<uuid>&$limit=<n>&$trail=<cursor>`
→ `{ items: [...], trail? }`

### Get Item
`GET /sink-items/<id>` → item object

## Pagination
All list endpoints use trail-based pagination. Pass `$trail` from previous response for next page. Default `$limit`: 50.
