# Phase 35 — Billing policy (stub-only enforcement)

## Policy
- Billing provider must be `stub`.
- No live SDKs (Stripe, etc.) are permitted in the Hub until a future phase explicitly enables them.

## Contract modules
- `apps/hub/src/lib/billing/*`
- `getBillingProvider()` returns stub provider.
- `assertBillingProviderIsStub()` is the guard function.

## Determinism
- No network calls.
- Stub IDs are stable for identical inputs.

## Non-goals
- No payments processing
- No webhooks
- No provider keys in code
