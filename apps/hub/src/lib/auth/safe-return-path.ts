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

type AuthStartOptions = {
  entry?: string | null;
  from?: string | null;
  loginHint?: string | null;
  manual?: string | null;
};

export function buildAuthStartPath({ entry, from, loginHint, manual }: AuthStartOptions) {
  const params = new URLSearchParams();
  const normalizedFrom = from ? normalizeAuthReturnPath(from) : "";
  const trimmedHint = loginHint?.trim();
  const trimmedEntry = entry?.trim();
  const manualFlag = manual?.trim();

  if (normalizedFrom && normalizedFrom !== DEFAULT_AUTH_RETURN_PATH) {
    params.set("from", normalizedFrom);
  }
  if (trimmedHint) {
    params.set("loginHint", trimmedHint);
  }
  if (trimmedEntry) {
    params.set("entry", trimmedEntry);
  }
  if (manualFlag) {
    params.set("manual", manualFlag);
  }

  const query = params.toString();
  return query ? `/api/auth/start/keycloak?${query}` : "/api/auth/start/keycloak";
}
