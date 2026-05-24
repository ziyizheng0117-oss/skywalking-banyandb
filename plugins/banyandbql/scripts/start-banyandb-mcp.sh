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
plugin_root="$(cd "${script_dir}/.." && pwd)"

resolve_entrypoint() {
  if [[ -n "${BANYANDB_MCP_ENTRYPOINT:-}" ]]; then
    echo "${BANYANDB_MCP_ENTRYPOINT}"
    return
  fi

  if [[ -n "${SKYWALKING_BANYANDB_HOME:-}" ]]; then
    echo "${SKYWALKING_BANYANDB_HOME}/mcp/dist/index.js"
    return
  fi

  echo "$(cd "${plugin_root}/../.." && pwd)/mcp/dist/index.js"
}

entrypoint="$(resolve_entrypoint)"

if ! command -v node >/dev/null 2>&1; then
  echo "node is required to run the BanyanDB MCP server. Install Node.js 24.6.0 or newer." >&2
  exit 127
fi

if [[ ! -f "${entrypoint}" ]]; then
  echo "BanyanDB MCP server is not built: ${entrypoint}" >&2
  echo "Build it with: cd <skywalking-banyandb>/mcp && npm install && npm run build" >&2
  echo "If the plugin was copied outside the repository, set SKYWALKING_BANYANDB_HOME or BANYANDB_MCP_ENTRYPOINT." >&2
  exit 1
fi

export BANYANDB_ADDRESS="${BANYANDB_ADDRESS:-localhost:17900}"
export TRANSPORT="${TRANSPORT:-stdio}"
export MCP_HOST="${MCP_HOST:-127.0.0.1}"
export MCP_MAX_BODY_BYTES="${MCP_MAX_BODY_BYTES:-1048576}"
export MCP_RATE_LIMIT_WINDOW_MS="${MCP_RATE_LIMIT_WINDOW_MS:-60000}"
export MCP_RATE_LIMIT_MAX_REQUESTS="${MCP_RATE_LIMIT_MAX_REQUESTS:-60}"
export MCP_RATE_LIMIT_MAX_CLIENTS="${MCP_RATE_LIMIT_MAX_CLIENTS:-10000}"

exec node "${entrypoint}"
