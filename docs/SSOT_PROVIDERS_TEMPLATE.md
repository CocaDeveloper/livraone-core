# LivraOne SSOT Provider Keys (Template)

**File:** `/etc/livraone/hub.env`  
**Rule:** SSOT only. Do not store secrets in repo. Do not print secret values in logs.

## Email (disabled by default)
- EMAIL_PROVIDER=stub|ses|postmark
- EMAIL_FROM=__SET_ME__
- EMAIL_API_KEY=__SET_ME__
- EMAIL_REGION=__SET_ME__

## SMS (disabled by default)
- SMS_PROVIDER=stub|twilio
- SMS_FROM=__SET_ME__
- SMS_ACCOUNT_SID=__SET_ME__
- SMS_AUTH_TOKEN=__SET_ME__

## Billing (disabled by default)
- BILLING_PROVIDER=stub|stripe
- STRIPE_SECRET_KEY=__SET_ME__
- STRIPE_WEBHOOK_SECRET=__SET_ME__
- STRIPE_PRICE_BASIC=__SET_ME__
- STRIPE_PRICE_PRO=__SET_ME__

## Behavior
- In `stub` mode, the system must work offline:
  - Email/SMS “send” writes to DB/outbox table
  - Billing uses local fake state machine for subscriptions
