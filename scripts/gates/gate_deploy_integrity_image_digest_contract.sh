#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

# Scan repo for docker compose manifests
mapfile -t files < <(find . -maxdepth 6 -type f \( -name '*compose*.yml' -o -name '*compose*.yaml' -o -name 'docker-compose*.yml' -o -name 'docker-compose*.yaml' \) | sort)
[[ ${#files[@]} -gt 0 ]] || fail "no compose manifests found to enforce"

bad=0
for f in "${files[@]}"; do
  # Only evaluate lines with "image:" (ignore commented lines)
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*image:[[:space:]]* ]] || continue

    img="${line#*:}"
    img="$(echo "$img" | tr -d '"' | tr -d "'" | xargs)"

    # Allow explicit local build images (e.g., livraone-hub:local) and HUB_IMAGE overrides.
    if [[ "$img" == *":local"* ]] || [[ "$img" == *"\${HUB_IMAGE"* ]]; then
      continue
    fi

    # Enforce digest pinning: must contain "@sha256:"
    if [[ "$img" != *"@sha256:"* ]]; then
      echo "FAIL: image not digest-pinned in $f: $line" >&2
      bad=1
    fi

    # Disallow :latest explicitly (even if digest present, which would be odd)
    if [[ "$img" == *":latest"* ]]; then
      echo "FAIL: :latest forbidden in $f: $line" >&2
      bad=1
    fi
  done < "$f"
done

[[ "$bad" -eq 0 ]] || exit 1
echo "PASS"
