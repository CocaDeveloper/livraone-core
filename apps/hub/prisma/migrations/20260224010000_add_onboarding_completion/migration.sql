CREATE TABLE IF NOT EXISTS onboarding_completion (
  user_id uuid PRIMARY KEY,
  completed boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
