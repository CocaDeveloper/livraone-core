import type { Subscription, PlanId, SubscriptionStatus } from './types';

/**
 * Stub store (in-memory). Deterministic default for tenants without record.
 * Future phase can back this with DB schema + migrations.
 */
const STORE = new Map<string, Subscription>();

function nowIso(): string {
  return new Date().toISOString();
}

export function getOrInitSubscription(tenantId: string): Subscription {
  const existing = STORE.get(tenantId);
  if (existing) return existing;

  const t = nowIso();
  const sub: Subscription = {
    tenantId,
    planId: 'free',
    status: 'trialing',
    createdAt: t,
    updatedAt: t,
  };
  STORE.set(tenantId, sub);
  return sub;
}

export function setSubscription(tenantId: string, planId: PlanId, status: SubscriptionStatus): Subscription {
  const cur = getOrInitSubscription(tenantId);
  const updated: Subscription = { ...cur, planId, status, updatedAt: nowIso() };
  STORE.set(tenantId, updated);
  return updated;
}

export function clearSubscription(tenantId: string): void {
  STORE.delete(tenantId);
}
