# opensink-memory

An [OpenClaw](https://github.com/openclaw/openclaw) skill that gives AI agents persistent, searchable memory using [OpenSink](https://opensink.com) Sinks.

## What it does

Store and retrieve memories as OpenSink Sink Items. Agents can:

- **Push** memories (facts, decisions, preferences, events, notes)
- **List** recent memories
- **Search** memories by keyword
- **Get** a specific memory by ID

Memories are stored in the cloud via OpenSink's API — they survive restarts, work across sessions, and are searchable.

## Install

```bash
openclaw skills install github:opensinkai/opensink-openclaw-memory
```

Or clone and install locally:

```bash
git clone https://github.com/opensinkai/opensink-openclaw-memory.git
openclaw skills install ./opensink-openclaw-memory
```

## Setup

1. **Get an OpenSink API key** at [app.opensink.com](https://app.opensink.com)
2. **Create a Memory Sink** (or use the init script):
   ```bash
   export OPENSINK_API_KEY="your-api-key"
   bash scripts/init-memory-sink.sh
   ```
3. **Configure your agent's `TOOLS.md`** with the API key and Sink ID:
   ```markdown
   ## OpenSink Memory
   - **API Key:** `osk_...`
   - **Sink ID:** `019c...`
   ```

The skill reads `OPENSINK_API_KEY` and `OPENSINK_SINK_ID` from environment variables.

## Usage

The skill is used automatically by OpenClaw agents when they need to remember or recall something. You can also run the script directly:

```bash
export OPENSINK_API_KEY="your-key"
export OPENSINK_SINK_ID="your-sink-id"

# Store a memory
bash scripts/opensink-memory.sh push "Dan prefers dark mode" "preference"

# List recent memories
bash scripts/opensink-memory.sh list

# Search memories
bash scripts/opensink-memory.sh search "dark mode"

# Get a specific memory
bash scripts/opensink-memory.sh get <item-id>
```

## Memory types

- `fact` — things that are true
- `preference` — user preferences
- `decision` — choices made
- `event` — things that happened
- `note` — general notes

## Requirements

- `curl` and `python3` (no npm dependencies)
- An [OpenSink](https://opensink.com) account with API access

## License

MIT
