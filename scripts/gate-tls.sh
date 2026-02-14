#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"
compose=infra/compose.yaml
host=hub.livraone.com
max_wait=300
interval=15
allowed=(200 301 302 303 404)

if [[ "${LIVRAONE_SKIP_DOCKER:-0}" -eq 1 ]]; then
  echo "gate-tls: LIVRAONE_SKIP_DOCKER=1, skipping TLS gate"
  exit 0
fi

fetch_logs() {
  if [[ -z "${RUN_GATES_SECRETS_LOADED:-}" ]]; then
    bash $ROOT_DIR/scripts/load-secrets.sh
  fi
  docker compose -f "$compose" logs traefik --tail 200 2>/dev/null || true
}

# env preloaded by scripts/run-gates.sh

if [[ -z "${CF_API_TOKEN:-}" ]]; then
  echo "gate-tls: CF_API_TOKEN is empty"
  exit 1
fi
if [[ -z "${ACME_EMAIL:-}" ]]; then
  echo "gate-tls: ACME_EMAIL is empty"
  exit 1
fi

classify_logs() {
  local logs="$1"
  if [[ -z "$logs" ]]; then
    echo "TLS handshake failure"
    return
  fi
  if grep -qi "credentials information are missing" <<< "$logs"; then
    echo "Cloudflare credentials missing"
    return
  fi
  if grep -qi "invalidContact" <<< "$logs"; then
    echo "invalid ACME contact"
    return
  fi
  if grep -qi "rate limit" <<< "$logs"; then
    echo "certificate rate limit"
    return
  fi
  if grep -qi "DNS" <<< "$logs" && grep -qi "error" <<< "$logs"; then
    echo "DNS challenge failure"
    return
  fi
  if grep -qi "challenge failed" <<< "$logs"; then
    echo "ACME challenge failed"
    return
  fi
  echo "TLS handshake failure"
}

fatal_break=0
start_time=$SECONDS
handle_failure() {
  last_reason="$1"
  final_logs=$(fetch_logs)
  final_log_reason=$(classify_logs "$final_logs")
  if [[ "$final_log_reason" != "TLS handshake failure" ]]; then
    fatal_break=1
  fi
}

last_reason=""
final_logs=""
final_log_reason="TLS handshake failure"
end_time=$((SECONDS + max_wait))
while ((SECONDS < end_time)); do
  current_logs=$(fetch_logs)
  current_log_reason=$(classify_logs "$current_logs")
  if [[ "$current_log_reason" != "TLS handshake failure" ]]; then
    last_reason="log reason detected: $current_log_reason"
    final_logs="$current_logs"
    final_log_reason="$current_log_reason"
    fatal_break=1
    break
  fi
  set +e
  location_output=$(curl -sI "http://$host")
  location_ret=$?
  set -e
  if [[ $location_ret -ne 0 ]]; then
    handle_failure "failed to reach http://$host (curl exit $location_ret)"
    [[ $fatal_break -eq 1 ]] && break
    sleep $interval
    continue
  fi
  redirect=$(awk -F': ' '/[Ll]ocation/ {print $2; exit}' <<< "$location_output" || true)
  if [[ -z "$redirect" ]]; then
    handle_failure "missing Location header for http://$host"
    [[ $fatal_break -eq 1 ]] && break
    sleep $interval
    continue
  fi
  if [[ "$redirect" != https://* ]]; then
    handle_failure "expected HTTP redirect to HTTPS but got $redirect"
    [[ $fatal_break -eq 1 ]] && break
    sleep $interval
    continue
  fi

  set +e
  status=$(curl -s -o /dev/null -w '%{http_code}' -I "https://$host")
  curl_rc=$?
  set -e
  if [[ $curl_rc -ne 0 ]]; then
    handle_failure "curl exit $curl_rc when requesting https://$host"
    [[ $fatal_break -eq 1 ]] && break
    sleep $interval
    continue
  fi
  if [[ ! " ${allowed[*]} " =~ " ${status} " ]]; then
    handle_failure "unexpected HTTPS status $status for $host"
    [[ $fatal_break -eq 1 ]] && break
    sleep $interval
    continue
  fi

  issuer_output=$(timeout 5 openssl s_client -servername "$host" -connect "$host:443" </dev/null 2>&1)
  issuer_line=$(awk -F'issuer=' '/issuer=/ {print; exit}' <<< "$issuer_output" || true)
  if [[ -z "$issuer_line" ]]; then
    handle_failure "no peer certificate delivered"
    [[ $fatal_break -eq 1 ]] && break
    sleep $interval
    continue
  fi
  if [[ "$issuer_line" != *"Let's Encrypt"* ]]; then
    handle_failure "certificate issuer mismatch: $issuer_line"
    [[ $fatal_break -eq 1 ]] && break
    sleep $interval
    continue
  fi

  printf "TLS gate OK (HTTP status %s, issuer: %s)\n" "$status" "$issuer_line"
  exit 0
done

if [[ -z "$final_logs" ]]; then
  final_logs=$(fetch_logs)
  final_log_reason=$(classify_logs "$final_logs")
fi
elapsed=$((SECONDS - start_time))
cat <<SUMMARY
TLS gate failed after ${elapsed}s: $last_reason (log indicator: $final_log_reason)
Last 200 Traefik log lines:
$final_logs
SUMMARY
exit 1
