#!/usr/bin/env bash
set -euo pipefail
# Deterministic marketing lint/typecheck (no secrets)
cd "$(git rev-parse --show-toplevel)/apps/marketing"
npm -s run lint
npm -s run typecheck
