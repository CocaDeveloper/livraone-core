// ---------------------------------------------------------
// Phase 50 — Security headers baseline (no redesign).
// Applied via middleware on all responses that pass through.
// ---------------------------------------------------------

export type SetHeader = (k: string, v: string) => void;

export function applySecurityHeaders(set: SetHeader) {
  // Conservative baseline headers
  set("X-Content-Type-Options", "nosniff");
  set("X-Frame-Options", "DENY");
  set("Referrer-Policy", "strict-origin-when-cross-origin");
  set("Permissions-Policy", "geolocation=(), microphone=(), camera=()");
  // HSTS should only be used behind HTTPS; we assume prod is TLS (Traefik + CF)
  set("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
  // Minimal CSP (avoid breaking app): no inline banning here
  set("Content-Security-Policy", "default-src 'self'; img-src 'self' data: https:; object-src 'none'; base-uri 'self'; frame-ancestors 'none'");
}
