/**
 * Tenant isolation foundations (Phase 33)
 * - No auth model change.
 * - Pure app-layer contract: every tenant-scoped query must require tenantId.
 *
 * Resolution strategy (baseline):
 * - Prefer explicit tenant id from request context if available.
 * - Fallback to host/subdomain parsing when used in routing.
 *
 * IMPORTANT: This is a contract module. It must not read secrets.
 */

export type TenantId = string;

export function parseTenantFromHost(host: string | null | undefined): TenantId | null {
  if (!host) return null;
  // Strip port if any
  const h = host.split(':')[0].toLowerCase();
  // Example: {tenant}.livraone.com or {tenant}.hub.livraone.com
  const parts = h.split('.');
  if (parts.length < 3) return null;

  // Heuristic: take first label as tenant slug unless it's known shared hostnames
  const first = parts[0];
  const blocked = new Set(['www', 'livraone', 'hub', 'auth', 'invoice', 'automation', 'apps', 'staging', 'localhost']);
  if (blocked.has(first)) return null;

  return first;
}

export function requireTenantId(tenantId: TenantId | null | undefined): TenantId {
  if (!tenantId || tenantId.trim().length === 0) {
    throw new Error('TENANT_REQUIRED');
  }
  return tenantId;
}

export function withTenantWhere<T extends Record<string, any>>(tenantId: TenantId, where: T): T & { tenantId: TenantId } {
  // Enforce tenantId present in all tenant-scoped queries
  return { ...where, tenantId };
}
