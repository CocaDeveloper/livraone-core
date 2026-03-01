# Phase 36 — Notifications dispatcher (stub-only)

## Policy
- Notifications provider must be `stub`.
- No live email/sms SDKs are permitted in the Hub until a future phase explicitly enables them.

## Contract
- `dispatchNotification(msg)` is the only entrypoint.
- Stub dispatch enqueues into an in-memory outbox (no IO, no network).

## Non-goals
- No provider integrations (SendGrid, SES, Twilio, etc.)
- No webhook/receipt processing
