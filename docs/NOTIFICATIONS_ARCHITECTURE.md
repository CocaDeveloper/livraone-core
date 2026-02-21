# Notifications Architecture

## Goals
- Minimize cost while preserving delivery reliability
- Prefer cheap channels first and escalate only when needed

## Cheapest-First Routing
1. Push notification (if device token present and active)
2. Email (fallback when push is unavailable)
3. SMS (final fallback only when critical)

## Presence Detection
Maintain lightweight presence signals (recent activity, token validity, last device ping). Use presence to avoid unnecessary SMS.

## Fallback Ladder
Each attempt records a delivery state. If a channel fails or times out, the system escalates to the next channel with controlled retries.

## Delivery Ledger
A durable ledger records notification intent, channel attempts, outcomes, and timestamps. This supports idempotency, auditability, and cost tracking.
