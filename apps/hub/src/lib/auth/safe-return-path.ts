const DEFAULT_AUTH_RETURN_PATH = "/";
const BLOCKED_PREFIXES = ["/api/auth", "/login", "/logout", "/post-auth"];

export function normalizeAuthReturnPath(value?: string | null) {
  if (!value) return DEFAULT_AUTH_RETURN_PATH;

  const candidate = value.trim();
  if (!candidate.startsWith("/") || candidate.startsWith("//")) {
    return DEFAULT_AUTH_RETURN_PATH;
  }

  try {
    const url = new URL(candidate, "https://hub.livraone.com");
    const path = `${url.pathname}${url.search}${url.hash}`;
    if (BLOCKED_PREFIXES.some((prefix) => path === prefix || path.startsWith(`${prefix}/`) || path.startsWith(`${prefix}?`))) {
      return DEFAULT_AUTH_RETURN_PATH;
    }
    return path || DEFAULT_AUTH_RETURN_PATH;
  } catch {
    return DEFAULT_AUTH_RETURN_PATH;
  }
}

export function buildPostAuthCallback(value?: string | null) {
  const from = normalizeAuthReturnPath(value);
  if (from === DEFAULT_AUTH_RETURN_PATH) {
    return "/post-auth";
  }

  const params = new URLSearchParams({ from });
  return `/post-auth?${params.toString()}`;
}
