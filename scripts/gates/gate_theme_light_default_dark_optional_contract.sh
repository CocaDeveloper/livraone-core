#!/usr/bin/env bash
set -euo pipefail
fail(){ echo "FAIL: $*" >&2; exit 1; }

f="packages/ui/src/globals.css"
[[ -f "$f" ]] || fail "missing $f"

grep -q '^:root' "$f" || fail "globals.css missing :root"
grep -q '^\.dark' "$f" || fail "globals.css missing .dark"

# Ensure light default isn't dark-like: bg lightness should be high-ish (we enforce the exact value we set)
grep -q -- '--bg: 210 40% 98%' "$f" || fail "light default bg token not set as expected"

# Ensure dark mode exists
grep -q -- '--bg: 222 47% 7%' "$f" || fail "dark bg token missing"

# Hub login must include optional toggle
h="apps/hub/app/login/LoginPageClient.tsx"
[[ -f "$h" ]] || h="apps/hub/app/login/page.tsx"
[[ -f "$h" ]] || fail "missing login bootstrap implementation"
grep -q 'ThemeToggle' "$h" || fail "hub login missing ThemeToggle"

# Toggle must persist theme
th="apps/hub/components/theme/ThemeToggle.tsx"
[[ -f "$th" ]] || fail "missing $th"
grep -q 'const KEY = "livraone_theme"' "$th" || fail "toggle key missing"
grep -q 'localStorage.getItem(KEY)' "$th" || fail "toggle must read persisted theme"
grep -q 'localStorage.setItem(KEY' "$th" || fail "toggle must persist theme"

echo "PASS"
