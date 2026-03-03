CREATE TABLE IF NOT EXISTS provider_outbox (
  id text PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  kind text NOT NULL,
  external_id text NOT NULL,
  "to" text NOT NULL,
  payload_json text NOT NULL
);

CREATE INDEX IF NOT EXISTS provider_outbox_kind_created_at_idx
  ON provider_outbox (kind, created_at);

CREATE TABLE IF NOT EXISTS stub_entitlements (
  tenant_id text PRIMARY KEY,
  plan text NOT NULL,
  active boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now()
);
