#!/usr/bin/env bash
#
# Licensed to Apache Software Foundation (ASF) under one or more contributor
# license agreements. See the NOTICE file distributed with this work for
# additional information regarding copyright ownership. Apache Software
# Foundation (ASF) licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../../.." && pwd)"
plugin_root="${repo_root}/plugins/banyandbql"
mcp_root="${repo_root}/mcp"
output_dir="${repo_root}/dist/codex-plugins"
bundle_name="banyandbql-codex-plugin"
archive_path="${output_dir}/${bundle_name}.tar.gz"
staging_root="$(mktemp -d)"

cleanup() {
  rm -rf "${staging_root}"
}
trap cleanup EXIT

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required to build the portable BanyanDB QL plugin bundle." >&2
  exit 127
fi

if [[ ! -f "${plugin_root}/.codex-plugin/plugin.json" ]]; then
  echo "plugin manifest not found: ${plugin_root}/.codex-plugin/plugin.json" >&2
  exit 1
fi

if [[ ! -f "${repo_root}/.agents/plugins/marketplace.json" ]]; then
  echo "marketplace manifest not found: ${repo_root}/.agents/plugins/marketplace.json" >&2
  exit 1
fi

if [[ ! -d "${mcp_root}/dist" ]]; then
  echo "MCP dist is missing. Building it now..." >&2
  (cd "${mcp_root}" && npm ci && npm run build)
fi

bundle_root="${staging_root}/${bundle_name}"
mkdir -p "${bundle_root}/.agents/plugins" "${bundle_root}/plugins" "${bundle_root}/mcp"

cp "${repo_root}/.agents/plugins/marketplace.json" "${bundle_root}/.agents/plugins/marketplace.json"
cp -R "${plugin_root}" "${bundle_root}/plugins/"
cp -R "${mcp_root}/dist" "${bundle_root}/mcp/dist"
cp "${mcp_root}/package.json" "${bundle_root}/mcp/package.json"
cp "${mcp_root}/package-lock.json" "${bundle_root}/mcp/package-lock.json"

(cd "${bundle_root}/mcp" && npm ci --omit=dev)

cat > "${bundle_root}/README.md" <<'README'
# BanyanDB QL Codex Plugin Bundle

This bundle contains the BanyanDB QL Codex plugin, its marketplace manifest, the compiled BanyanDB MCP server, and runtime Node dependencies.

## Install

1. Extract this archive.
2. Add the extracted directory as a local Codex plugin marketplace.
3. Install or enable the `banyandbql` plugin from that marketplace.

## Configure

The plugin defaults to `BANYANDB_ADDRESS=localhost:17900`.

For a remote BanyanDB instance, set `BANYANDB_ADDRESS` in the environment used to launch Codex, or edit:

```text
plugins/banyandbql/.mcp.json
```

The bundled MCP server is started by:

```text
plugins/banyandbql/scripts/start-banyandb-mcp.sh
```
README

mkdir -p "${output_dir}"
tar -C "${staging_root}" -czf "${archive_path}" "${bundle_name}"
echo "${archive_path}"
