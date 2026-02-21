#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

fail(){ echo "FAIL: $*" >&2; exit 1; }

wf_dir=".github/workflows"

while IFS= read -r line; do
  content="$(printf '%s' "$line" | cut -d: -f3-)"
  if printf '%s' "$content" | rg -q "(echo|printf).*VPS_(HOST|USER|SSH_PORT)"; then
    if printf '%s' "$content" | rg -F -q '=$(printf' || \
       printf '%s' "$content" | rg -F -q '="$(printf' || \
       printf '%s' "$content" | rg -F -q '=$(echo' || \
       printf '%s' "$content" | rg -F -q '="$(echo'; then
      continue
    fi
    fail "workflow prints VPS host/user/port"
  fi
done < <(rg -n "(echo|printf).*VPS_(HOST|USER|SSH_PORT)" "$wf_dir" || true)

	while IFS= read -r line; do
	  content="$(printf '%s' "$line" | cut -d: -f3-)"
	  if printf '%s' "$content" | rg -q "(echo|printf).*VPS_SSH_KEY"; then
	    # Allow writing the key to a file for SSH usage; forbid printing to logs.
	    if printf '%s' "$content" | rg -q '>/tmp/|deploy_key|key_file' ; then
	      continue
	    fi
	    fail "workflow prints SSH key material"
	  fi
	done < <(rg -n "(echo|printf).*VPS_SSH_KEY" "$wf_dir" || true)

if rg -n "host_len|key_len|ssh_key_len" "$wf_dir" >/dev/null; then
  fail "workflow logs secret lengths"
fi

if rg -n "VPS_.*length|length.*VPS_" "$wf_dir" >/dev/null; then
  fail "workflow logs secret-derived lengths"
fi

if rg -n "VPS_.*wc -c|wc -c.*VPS_" "$wf_dir" >/dev/null; then
  fail "workflow measures secret length"
fi

compose="ops/compose/observability/docker-compose.yml"
if [ -f "$compose" ]; then
  if rg -n "traefik\\.http\\.routers\\.(grafana|prometheus|cadvisor|node_exporter)" "$compose" >/dev/null; then
    fail "public metrics router detected"
  fi
  if rg -n "0\\.0\\.0\\.0:" "$compose" >/dev/null; then
    fail "public bind to 0.0.0.0 detected"
  fi
  if rg -n "\\[::\\]:" "$compose" >/dev/null; then
    fail "public bind to [::] detected"
  fi
  if rg -n '^[[:space:]]*- "?[0-9]{1,5}:[0-9]{1,5}"?' "$compose" >/dev/null; then
    fail "public host port mapping detected"
  fi
fi

docs_dir="docs"
if [ -d "$docs_dir" ]; then
  if rg -n 'ghp_[A-Za-z0-9]+' "$docs_dir" >/dev/null; then
    fail "GitHub token detected in docs"
  fi
  if rg -n -i 'BEGIN .*PRIVATE KEY' "$docs_dir" >/dev/null; then
    fail "private key material detected in docs"
  fi
  if rg -n 'ssh-rsa [A-Za-z0-9+/=]+' "$docs_dir" >/dev/null; then
    fail "SSH public key material detected in docs"
  fi
fi

echo "security contract OK"
