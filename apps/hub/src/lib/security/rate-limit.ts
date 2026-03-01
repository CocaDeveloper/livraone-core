// ---------------------------------------------------------
// Phase 50 — In-memory rate limiter (best-effort).
// NOTE: per-process only; no external store.
// Default OFF unless RATE_LIMIT_ENABLED=1.
// ---------------------------------------------------------

function envBool(v: string | undefined): boolean {
  if (!v) return false;
  return v === "1" || v.toLowerCase() === "true" || v.toLowerCase() === "yes";
}

type Bucket = { tokens: number; last: number };

const buckets = new Map<string, Bucket>();

export type RateLimitConfig = {
  enabled: boolean;
  // tokens per window
  limit: number;
  // window ms
  windowMs: number;
};

export function getRateLimitConfigFromEnv(env: NodeJS.ProcessEnv): RateLimitConfig {
  const enabled = envBool(env.RATE_LIMIT_ENABLED);
  if (!enabled) return { enabled: false, limit: 0, windowMs: 0 };

  const limit = Math.max(1, Math.min(10000, Number(env.RATE_LIMIT_LIMIT ?? 120)));
  const windowMs = Math.max(1000, Math.min(3600_000, Number(env.RATE_LIMIT_WINDOW_MS ?? 60_000)));
  return { enabled: true, limit, windowMs };
}

export function rateLimitAllowOrThrow(key: string, cfg: RateLimitConfig) {
  if (!cfg.enabled) return;

  const now = Date.now();
  const b = buckets.get(key) ?? { tokens: cfg.limit, last: now };
  const elapsed = now - b.last;

  // refill each window
  if (elapsed >= cfg.windowMs) {
    b.tokens = cfg.limit;
    b.last = now;
  }

  if (b.tokens <= 0) {
    buckets.set(key, b);
    throw new Error("rate_limited");
  }

  b.tokens -= 1;
  buckets.set(key, b);
}
