# Phase History (9-12)

## Phase 9
- Stabilized Hub authentication and gate scripts
- Prepared CI gates for consistent enforcement

## Phase 10
- Gates workflow validated in CI
- Gate runner scripts confirmed in repo

## Phase 11
- Added staging and production deploy workflows
- Environments created with protection for production
- Rollback script and deployment model documentation added

## Phase 12
- Staging deploy executed end-to-end
- Health checks verified post-deploy
- Rollback drill completed and validated
- Runbook documented

## Phase 19
- DNS override fix completed and verified
- SSOT loader added (`scripts/lib/ssot_env.sh`)
- Gate added: `scripts/gates/gate_required_auth_env.sh`
- Evidence export flow and sha256 notarization added
- Branch history rewrite performed to fix git identity; force-pushed with `--force-with-lease`

## Phase 56
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase56-*/phase56-closeout-*).

## Phase 57
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase57-*/phase57-closeout-*).

## Phase 58
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase58-*/phase58-closeout-*).

## Phase 59
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase59-*/phase59-closeout-*).

## Phase 60
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase60-*/phase60-closeout-*).

## Phase 61
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase61-*/phase61-closeout-*).

## Phase 62
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase62-*/phase62-closeout-*).

## Phase 63
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase63-*/phase63-closeout-*).

## Phase 64
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase64-*/phase64-closeout-*).

## Phase 65
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase65-*/phase65-closeout-*).

## Phase 66
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase66-*/phase66-closeout-*).

## Phase 67
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase67-*/phase67-closeout-*).

## Phase 68
- Status: CLOSED
- Notes: See evidence bundles under /srv/livraone/evidence (phase68-*/phase68-closeout-*).

## Phase 69
- Status: CLOSED (docs-only governance hygiene)
- Notes:
  - Closed legacy/conflicting PRs as stale/obsolete (#4, #12) with evidence.
  - Closed legacy script-only PR as stale/obsolete (#13) with evidence.
  - PR backlog evidence:
    - /srv/livraone/evidence/pr-close-legacy-20260303-205905
    - /srv/livraone/evidence/pr-backlog-after-close-20260303-210030

## Phase 72
- Status: OPEN
- Notes:
  - Added auth loop debug + smoke scripts (no secrets printed).
  - Documented NEXTAUTH_URL in SSOT contract and enforced SSOT-sourced NEXTAUTH_URL.
  - Added auth redirect contract gate and enforced NEXTAUTH_TRUST_HOST in hub compose.
