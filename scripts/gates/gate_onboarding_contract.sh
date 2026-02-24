#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PAGE="$ROOT_DIR/apps/hub/app/onboarding/page.tsx"
LIB="$ROOT_DIR/apps/hub/lib/onboarding.ts"
SCHEMA="$ROOT_DIR/apps/hub/prisma/schema.prisma"
MIG_DIR="$ROOT_DIR/apps/hub/prisma/migrations/20260224000000_onboarding_completion"
MIG_SQL="$MIG_DIR/migration.sql"

fail(){ echo "FAIL: $*" >&2; exit 1; }
pass(){ echo "PASS: gate_onboarding_contract"; exit 0; }

[ -f "$PAGE" ] || fail "$PAGE missing"
grep -q "Onboarding contract" "$PAGE" || fail "$PAGE lacks onboarding heading"
grep -q "getOnboardingSteps" "$PAGE" || fail "$PAGE must reference getOnboardingSteps"

[ -f "$LIB" ] || fail "$LIB missing"
grep -q "getOnboardingSteps" "$LIB" || fail "$LIB must export getOnboardingSteps"

grep -q "model OnboardingCompletion" "$SCHEMA" || fail "schema missing OnboardingCompletion model"

[ -d "$MIG_DIR" ] || fail "migration directory $MIG_DIR missing"
[ -f "$MIG_SQL" ] || fail "$MIG_SQL missing"
grep -q "CREATE TABLE onboarding_completions" "$MIG_SQL" || fail "$MIG_SQL must define onboarding_completions table"

pass
