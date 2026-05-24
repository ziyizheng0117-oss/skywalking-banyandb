---
name: banyandbql
description: Use when the user asks Codex to query BanyanDB, generate or execute BydbQL, inspect BanyanDB schemas, or analyze a service/trace/log/metric symptom with BanyanDB data.
---

# BanyanDB QL

Use the `banyandb` MCP server from this plugin. Its tools are:

- `list_groups_schemas`: discover groups and resource names.
- `get_generate_bydbql_prompt`: fetch the live schema-aware prompt for converting a user request into BydbQL.
- `list_resources_bydbql`: execute a read-only BydbQL query and return results.

## Query Workflow

1. Discover schema before generating a query unless the user provided an exact BydbQL statement and explicitly asked only to run it.
2. Call `list_groups_schemas` with `resource_type="groups"`.
3. List likely resource types for relevant groups using `resource_type` values `streams`, `measures`, `traces`, and `properties`.
4. Call `get_generate_bydbql_prompt` with the user's natural language description and any explicit `resource_type`, `resource_name`, or `group` hints.
5. Use the returned prompt to produce the JSON object it asks for. Parse the `BydbQL` value exactly; do not execute malformed JSON or prose.
6. Execute the final query with `list_resources_bydbql`.
7. Return the BydbQL, a concise result summary, and any important caveats such as empty results, time range uncertainty, or schema assumptions.

## Direct BydbQL Execution

When the user provides BydbQL directly:

- Execute only read-only `SELECT` or `SHOW TOP` queries.
- Prefer adding no extra clauses unless the user asks for them.
- If execution fails because a resource, group, or indexed order field is wrong, discover schemas and propose the corrected query before retrying.

## Symptom Analysis Workflow

When the user describes a phenomenon instead of a query:

1. Extract concrete signals: service/entity names, trace IDs, endpoint names, status/error text, time window, and expected versus actual behavior.
2. If the time window is missing, default to a recent bounded window such as the last 30 minutes and state that assumption.
3. Discover available groups and resources before querying.
4. Generate and execute a small set of focused BydbQL queries. Prefer time-bounded queries and narrow filters over broad scans.
5. Correlate evidence across relevant measures, streams, traces, and properties when available.
6. Report findings as evidence-backed analysis: what was queried, what changed or failed, likely cause, confidence, and the next concrete check.

## Safety And Quality Rules

- Never invent group, resource, tag, or field names when live schema discovery is available.
- Do not use write, delete, update, DDL, shell, or network actions outside the MCP workflow for a user query.
- Keep queries bounded by time or limit when possible.
- If the MCP tools are unavailable, say that the BanyanDB plugin or MCP server is not loaded. Mention that the project MCP package must be built with `cd mcp && npm install && npm run build`.
- If the plugin was imported from a copied location instead of the repository, tell the user to set `SKYWALKING_BANYANDB_HOME` to the repository root or `BANYANDB_MCP_ENTRYPOINT` to the built `mcp/dist/index.js`.
- If BanyanDB is not local, tell the user to set `BANYANDB_ADDRESS` in `plugins/banyandbql/.mcp.json` or in the environment used to launch Codex.
