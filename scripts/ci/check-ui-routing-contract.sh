#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

DOC="docs/UI_ROUTING_CONTRACT.md"
MKT_HOME="apps/marketing/app/page.tsx"
HUB_LOGIN="apps/hub/app/login/page.tsx"
HUB_DASH="apps/hub/app/dashboard/page.tsx"
HUB_PAINEL="apps/hub/app/painel/page.tsx"
MW="apps/hub/middleware.ts"

if command -v rg >/dev/null 2>&1; then
  RG=(rg -n)
else
  RG=(grep -n -E)
fi

[ -f "$DOC" ] || { echo "missing $DOC" >&2; exit 1; }
[ -f "$MKT_HOME" ] || { echo "missing $MKT_HOME" >&2; exit 1; }
[ -f "$HUB_LOGIN" ] || { echo "missing $HUB_LOGIN" >&2; exit 1; }
[ -f "$HUB_DASH" ] || { echo "missing $HUB_DASH" >&2; exit 1; }

# painel alias must exist
[ -f "$HUB_PAINEL" ] || { echo "missing $HUB_PAINEL" >&2; exit 1; }

# Best-effort: painel is an alias (redirect to /dashboard or imports dashboard UI)
if ! "${RG[@]}" 'redirect\("/dashboard"\)' "$HUB_PAINEL" >/dev/null 2>&1 \
  && ! "${RG[@]}" 'from "\.\./dashboard/page"' "$HUB_PAINEL" >/dev/null 2>&1; then
  echo "/painel does not appear to alias /dashboard (expected redirect or reuse)" >&2
  exit 1
fi

# Best-effort: hub protected routes redirect unauth to /login via middleware
[ -f "$MW" ] || { echo "missing $MW" >&2; exit 1; }
"${RG[@]}" 'loginUrl\.pathname\s*=\s*"/login"' "$MW" >/dev/null || { echo "middleware must redirect unauth to /login" >&2; exit 1; }
"${RG[@]}" 'matcher:\s*\["/:path\*"\]' "$MW" >/dev/null || { echo "middleware matcher must cover routes" >&2; exit 1; }

echo "ui routing contract: OK"
