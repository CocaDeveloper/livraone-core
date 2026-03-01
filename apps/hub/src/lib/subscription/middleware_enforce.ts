import { NextRequest, NextResponse } from 'next/server';
import { getOrInitSubscription, assertAccess } from './index';
import { parseTenantFromHost, requireTenantId } from '../tenant';

/**
 * Phase 38 — Middleware-level subscription enforcement
 * Deterministic, stub-backed. No network. No secrets printed.
 *
 * Strategy:
 * - Resolve tenantId from host subdomain (baseline) using Phase 33 tenant contract.
 * - Evaluate subscription access using Phase 37 entitlement enforcement.
 * - If denied, redirect to /subscription/required (or /billing/* later).
 */

export function isPublicPath(pathname: string): boolean {
  // Explicit allowlist to avoid locking out auth/static.
  if (pathname.startsWith('/_next')) return true;
  if (pathname.startsWith('/favicon')) return true;
  if (pathname.startsWith('/robots')) return true;
  if (pathname.startsWith('/sitemap')) return true;

  // Auth + billing/subscription surfaces must remain reachable.
  if (pathname.startsWith('/login')) return true;
  if (pathname.startsWith('/api/auth')) return true;
  if (pathname.startsWith('/billing')) return true;
  if (pathname.startsWith('/subscription')) return true;

  // Public marketing pages inside hub (if any)
  if (pathname === '/' ) return true;

  return false;
}

export function enforceSubscription(req: NextRequest): NextResponse | null {
  const { pathname } = req.nextUrl;

  if (isPublicPath(pathname)) return null;

  const host = req.headers.get('host');
  const tenantParsed = parseTenantFromHost(host);
  if (!tenantParsed) return null;
  const tenantId = requireTenantId(tenantParsed);

  const sub = getOrInitSubscription(tenantId);

  try {
    assertAccess(sub);
    return null;
  } catch (_e) {
    const url = req.nextUrl.clone();
    url.pathname = '/subscription/required';
    url.searchParams.set('from', pathname);
    return NextResponse.redirect(url);
  }
}
