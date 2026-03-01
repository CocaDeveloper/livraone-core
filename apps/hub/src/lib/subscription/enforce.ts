import type { EntitlementDecision, Subscription } from './types';
import { entitlementsFor } from './entitlements';

export function evaluateAccess(sub: Subscription): EntitlementDecision {
  const ent = entitlementsFor(sub.planId, sub.status);
  if (!ent.canAccessApp) {
    return { ok: false, reason: 'SUBSCRIPTION_INACTIVE' };
  }
  return { ok: true };
}

export function assertAccess(sub: Subscription): void {
  const d = evaluateAccess(sub);
  if (!d.ok) throw new Error(d.reason ?? 'SUBSCRIPTION_REQUIRED');
}
