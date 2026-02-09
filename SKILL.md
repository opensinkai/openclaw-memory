---
name: opensink-memory
displayName: OpenSink Memory
description: Store and retrieve agent memories using OpenSink Sinks. Use when the agent needs to remember something persistently, recall past decisions/context/facts, search memories, or when the user says "remember this" and you want durable cloud-backed memory. Also use to list or browse stored memories.
metadata: {"openclaw":{"emoji":"🧠","requires":{"bins":["curl"],"env":["OPENSINK_API_KEY"]}}}
---

# OpenSink Memory

Persist agent memories as Items in an OpenSink Sink. Memories survive across sessions, machines, and agents.

## Setup

Requires two environment variables:
- `OPENSINK_API_KEY` — API key with `sinks:all` + `sink_items:all` scopes
- `OPENSINK_SINK_ID` — UUID of the Sink to use for memory (create one called "Memory" in the OpenSink dashboard, or use the init script)

## Quick Start

### Initialize (first time only)

```bash
# Create the Memory sink and print its ID
scripts/init-memory-sink.sh
```

Set the returned sink ID as `OPENSINK_SINK_ID`.

### Store a memory

```bash
scripts/opensink-memory.sh push "Dan prefers concise answers" "preference"
```

### Recall memories

```bash
# List recent memories
scripts/opensink-memory.sh list

# List memories of a specific type
scripts/opensink-memory.sh list --type decision

# Search memories by keyword
scripts/opensink-memory.sh search "Dan preference"

# Get a specific memory by ID
scripts/opensink-memory.sh get <item-id>
```

## Memory Item Structure

Each memory maps to a Sink Item:

| Sink Item field | Memory usage |
|---|---|
| `title` | The memory content (what to remember) |
| `body` | Optional additional context or details |
| `type` | Category: `fact`, `preference`, `decision`, `event`, `note` |
| `fields` | Structured metadata: `{ "tags": [...], "source": "..." }` |
| `occurred_at` | When the memory was formed |

## Types

Use these types to categorize memories:
- **fact** — something learned ("Dan's timezone is Europe/Chisinau")
- **preference** — a stated or inferred preference ("Dan likes concise replies")
- **decision** — a decision made ("Chose Sinks over dedicated memory feature")
- **event** — something that happened ("First boot on 2026-02-09")
- **note** — general notes or context

## Workflow

1. When the user says "remember this" or you learn something worth keeping → `push`
2. At session start or when context is needed → `list` or `search`
3. Use `fields.tags` for fine-grained filtering
4. Memories are append-only by default; update via the OpenSink dashboard if needed

## API Reference

See [references/api.md](references/api.md) for the full REST API details if the scripts need modification.
