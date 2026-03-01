# Phase 43 — Billing Activation Guardrail

## Goal
Prepare billing activation without enabling live provider.

## Feature Flag
BILLING_PROVIDER_ENABLED=true|false

- Must be set via SSOT (/etc/livraone/hub.env)
- No .env files allowed
- No direct SDK imports allowed

## Behavior
If disabled:
  - createCheckoutSession → BILLING_PROVIDER_DISABLED
  - webhook endpoint → BILLING_PROVIDER_DISABLED

If enabled:
  - Provider still throws LIVE_PROVIDER_NOT_IMPLEMENTED
  - No external SDK present yet

## Security
Deterministic gate blocks:
  - stripe imports
  - paypal imports
  - direct HTTP calls to billing providers
