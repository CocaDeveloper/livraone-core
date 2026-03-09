import { NextRequest, NextResponse } from "next/server";
import { buildPostAuthCallback, normalizeAuthReturnPath } from "@/lib/auth/safe-return-path";

export const runtime = "nodejs";

const NO_STORE_HEADERS = {
  "Cache-Control": "no-store, no-cache, must-revalidate, max-age=0, private",
  Pragma: "no-cache",
  Expires: "0",
  Vary: "Cookie"
};

type CookieHeaders = Headers & {
  getSetCookie?: () => string[];
};

function toBaseUrl(req: NextRequest) {
  return process.env.NEXTAUTH_URL ?? req.nextUrl.origin;
}

function setCookiesFrom(headers: Headers) {
  const cookieHeaders = headers as CookieHeaders;
  if (typeof cookieHeaders.getSetCookie === "function") {
    return cookieHeaders.getSetCookie();
  }

  const raw = headers.get("set-cookie");
  if (!raw) return [];
  return raw.split(/,(?=[^;,\s]+=)/g);
}

function cookieHeaderValue(existing: string, setCookies: string[]) {
  const cookies = setCookies.map((value) => value.split(";", 1)[0]).filter(Boolean);
  return [existing, ...cookies].filter(Boolean).join("; ");
}

function redirectWithCookies(location: string, setCookies: string[]) {
  const res = new NextResponse(null, {
    status: 302,
    headers: {
      location,
      ...NO_STORE_HEADERS
    }
  });

  for (const cookie of setCookies) {
    res.headers.append("set-cookie", cookie);
  }

  return res;
}

function manualFallback(req: NextRequest) {
  const search = req.nextUrl.searchParams;
  const baseUrl = toBaseUrl(req);
  const url = new URL("/login", baseUrl);
  url.searchParams.set("manual", "1");

  const loginHint = search.get("loginHint")?.trim();
  const entry = search.get("entry")?.trim();
  const from = search.get("from");

  if (loginHint) url.searchParams.set("loginHint", loginHint);
  if (entry) url.searchParams.set("entry", entry);
  if (from) url.searchParams.set("from", normalizeAuthReturnPath(from));

  return redirectWithCookies(url.toString(), []);
}

export async function GET(req: NextRequest) {
  const baseUrl = toBaseUrl(req);
  const loginHint = req.nextUrl.searchParams.get("loginHint")?.trim();
  const from = req.nextUrl.searchParams.get("from");
  const callbackUrl = buildPostAuthCallback(from);

  try {
    const csrfRes = await fetch(`${baseUrl}/api/auth/csrf`, {
      headers: {
        accept: "application/json",
        cookie: req.headers.get("cookie") ?? ""
      },
      cache: "no-store"
    });

    if (!csrfRes.ok) {
      return manualFallback(req);
    }

    const csrfJson = (await csrfRes.json()) as { csrfToken?: string };
    if (!csrfJson.csrfToken) {
      return manualFallback(req);
    }

    const csrfCookies = setCookiesFrom(csrfRes.headers);
    const signInUrl = new URL(`${baseUrl}/api/auth/signin/keycloak`);
    if (loginHint) signInUrl.searchParams.set("login_hint", loginHint);

    const signInRes = await fetch(signInUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        cookie: cookieHeaderValue(req.headers.get("cookie") ?? "", csrfCookies)
      },
      body: new URLSearchParams({
        csrfToken: csrfJson.csrfToken,
        callbackUrl
      }),
      redirect: "manual",
      cache: "no-store"
    });

    const location = signInRes.headers.get("location");
    if (!location || (signInRes.status !== 302 && signInRes.status !== 303)) {
      return manualFallback(req);
    }

    return redirectWithCookies(location, [...csrfCookies, ...setCookiesFrom(signInRes.headers)]);
  } catch {
    return manualFallback(req);
  }
}
