#!/usr/bin/env bash
set -euo pipefail

# PHASE9_NOWRITE_PUBLIC_IP: allow providing LIVRAONE_PUBLIC_IP at runtime and never write /etc here
if [[ -n "${LIVRAONE_PUBLIC_IP:-}" ]]; then
  if [[ "${LIVRAONE_PUBLIC_IP}" = "127.0.0.1" ]]; then
    echo "preflight: LIVRAONE_PUBLIC_IP cannot be 127.0.0.1" >&2
    exit 1
  fi
  echo "preflight: using LIVRAONE_PUBLIC_IP from environment: ${LIVRAONE_PUBLIC_IP}"
fi

cd /srv/livraone/livraone-core

if [[ $(id -un) != "livraone" && $(id -u) != 0 ]]; then
  echo "preflight: must run as livraone" >&2
  exit 1
fi
if [[ $(id -u) == 0 ]]; then
  echo "preflight: running as root for automation"
fi

discover_public_ip_local() {
  if [[ -n "${LIVRAONE_PUBLIC_IP:-}" ]]; then
    echo "$LIVRAONE_PUBLIC_IP"
    return 0
  fi
  while read -r ip; do
    [[ -z "$ip" ]] && continue
    case "$ip" in
      10.*|192.168.*|169.254.*|172.1[6-9].*|172.2[0-9].*|172.3[0-1].*|100.6[4-9].*|100.7[0-9].*|100.8[0-9].*|100.9[0-9].*|100.1[0-1][0-9].*|100.12[0-7].*)
        continue
        ;;
    esac
    echo "$ip"
    return 0
  done < <(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
  return 1
}

for bin in docker curl dig; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "preflight: missing $bin command"
    exit 1
  fi
done


bash /srv/livraone/livraone-core/scripts/load-secrets.sh
if ! docker compose version >/dev/null 2>&1; then
  echo "preflight: docker compose plugin is missing"
  exit 1
fi

if [[ -z "${CF_API_TOKEN:-}" ]]; then
  echo "preflight: CF_API_TOKEN must be set"
  exit 1
fi
if [[ ${#CF_API_TOKEN} -lt 20 ]]; then
  echo "preflight: CF_API_TOKEN looks too short (must be >=20 characters)"
  exit 1
fi
if [[ -z "${ACME_EMAIL:-}" ]]; then
  echo "preflight: ACME_EMAIL must be set"
  exit 1
fi

public_ip="$(discover_public_ip_local || true)"
if [[ -z "$public_ip" ]]; then
  echo "preflight: unable to discover public IP" >&2
  echo "preflight: please set LIVRAONE_PUBLIC_IP in /etc/livraone/hub.env for this host" >&2
  exit 1
fi

hosts=(auth.livraone.com hub.livraone.com invoice.livraone.com)
if [[ "${LIVRAONE_SKIP_DNS_CHECK:-0}" -eq 0 ]]; then
  for host in "${hosts[@]}"; do
    resolved=$(dig +short "$host" | grep -E ^[0-9.]+ | head -n1 || true)
    if [[ -z "$resolved" ]]; then
      echo "preflight: DNS lookup for $host failed"
      exit 1
    fi
    if [[ "$resolved" != "$public_ip" ]]; then
      echo "preflight: $host resolves to $resolved but expected $public_ip"
      exit 1
    fi
  done
else
  echo "preflight: LIVRAONE_SKIP_DNS_CHECK=1, bypassing DNS resolution checks"
fi

if [[ ! -f infra/acme/acme.json ]]; then
  echo "preflight: infra/acme/acme.json must exist with mode 600"
  exit 1
fi
if [[ "$(stat -c "%a" infra/acme/acme.json)" != "600" ]]; then
  echo "preflight: infra/acme/acme.json must be mode 600"
  exit 1
fi

echo "preflight: user, Docker, DNS, and environment variables look healthy"
if [[ -n "${ACME_CA_SERVER:-}" ]]; then
  echo "preflight: ACME_CA_SERVER is set to $ACME_CA_SERVER"
fi
cat <<SCOPES
preflight: Required Cloudflare token scopes: Zone.Zone:Read and Zone.DNS:Edit (zone-restricted to livraone.com).
SCOPES
