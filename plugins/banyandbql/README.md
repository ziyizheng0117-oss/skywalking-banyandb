# BanyanDB QL Codex Plugin

This plugin connects Codex to the BanyanDB MCP server in this repository.

## What It Provides

- Schema discovery for BanyanDB groups and resources.
- Natural-language to BydbQL generation using live schema hints.
- Read-only BydbQL execution through the existing MCP server.
- A Codex skill for symptom-driven BanyanDB troubleshooting.

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

## Codex Import

Use the repository marketplace at `.agents/plugins/marketplace.json`, or import this plugin folder directly:

```text
plugins/banyandbql
```

The plugin starts the MCP server with `plugins/banyandbql/scripts/start-banyandb-mcp.sh`.
