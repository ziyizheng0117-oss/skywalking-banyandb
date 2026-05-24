# BanyanDB QL Plugin

This plugin connects AI coding assistants (Claude Code and OpenAI Codex) to the BanyanDB MCP server in this repository.

## What It Provides

- Schema discovery for BanyanDB groups and resources.
- Natural-language to BydbQL generation using live schema hints.
- Read-only BydbQL execution through the existing MCP server.
- Symptom-driven BanyanDB troubleshooting and root cause analysis.

## Prerequisites

- Node.js 24.6.0 or newer.
- The MCP package built with:

```bash
cd mcp
npm install
npm run build
```

- BanyanDB reachable at `localhost:17900`, or set `BANYANDB_ADDRESS` for a different server.
- If the plugin is copied outside this repository, set `SKYWALKING_BANYANDB_HOME` to the repository root or `BANYANDB_MCP_ENTRYPOINT` to the built `mcp/dist/index.js`.

## Claude Code Setup

### Option 1: Project-level MCP configuration (recommended)

Add the MCP server to your project's `.claude/settings.json`:

```json
{
  "mcpServers": {
    "banyandb": {
      "command": "./plugins/banyandbql/scripts/start-banyandb-mcp.sh",
      "cwd": ".",
      "env": {
        "TRANSPORT": "stdio"
      }
    }
  }
}
```

Then the `CLAUDE.md` in this plugin directory will be picked up automatically when Claude Code operates within this project.

### Option 2: Plugin import

Import this plugin folder as a Claude Code plugin. The `.claude-plugin/plugin.json` manifest registers the MCP server and skill automatically.

### Option 3: Global MCP configuration

Add to `~/.claude/settings.json` for cross-project access:

```json
{
  "mcpServers": {
    "banyandb": {
      "command": "/path/to/skywalking-banyandb/plugins/banyandbql/scripts/start-banyandb-mcp.sh",
      "env": {
        "TRANSPORT": "stdio",
        "BANYANDB_ADDRESS": "localhost:17900"
      }
    }
  }
}
```

### Usage with Claude Code

Once configured, Claude Code can:

- Discover BanyanDB schemas automatically
- Generate BydbQL from natural language descriptions
- Execute queries and present structured results
- Perform multi-dimensional symptom analysis (correlating metrics, traces, and logs)

Example prompts:
```
List BanyanDB groups and show what measures are available
Query the last hour of service_cpm_minute metrics
Show me the last 50 traces for the payment service ordered by duration
Service X has high latency — investigate using BanyanDB
```

## Codex Setup

Use the repository marketplace at `.agents/plugins/marketplace.json`, or import this plugin folder directly:

```text
plugins/banyandbql
```

The plugin starts the MCP server with `plugins/banyandbql/scripts/start-banyandb-mcp.sh`.

## Architecture

```
plugins/banyandbql/
├── .claude-plugin/          # Claude Code plugin manifest
│   ├── plugin.json
│   └── marketplace.json
├── .codex-plugin/           # Codex plugin manifest
│   └── plugin.json
├── .mcp.json                # MCP server configuration (shared)
├── CLAUDE.md                # System instructions for Claude Code
├── README.md                # This file
├── scripts/
│   ├── start-banyandb-mcp.sh
│   └── package-banyandbql-plugin.sh
└── skills/
    ├── banyandbql/          # Codex skill
    │   └── SKILL.md
    └── banyandbql-claude/   # Claude Code skill
        └── SKILL.md
```

## Configure BanyanDB Address

By default the plugin connects to `localhost:17900`. For a remote instance:

- Set `BANYANDB_ADDRESS` in your shell environment, or
- Edit `.mcp.json` to add the env var, or
- Pass it through the MCP server configuration in your settings.json.
