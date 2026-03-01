/**
 * Phase 46 — Feature gating by plan (server-side)
 * Uses Phase 40 (subscription DB-backed) + Phase 37 entitlements mapping.
 * Deterministic: no network, no provider calls.
 */
import type { FeatureKey } from './types';
import { getOrInitSubscription, entitlementsFor } from '@/lib/subscription';

export class FeatureGateError extends Error {
  code: 'FEATURE_DISABLED';
  feature: FeatureKey;
  constructor(feature: FeatureKey) {
    super('FEATURE_DISABLED');
    this.code = 'FEATURE_DISABLED';
    this.feature = feature;
  }
}

export async function assertFeatureForTenant(tenantId: string, feature: FeatureKey): Promise<void> {
  const sub = await getOrInitSubscription(tenantId);
  const ent = entitlementsFor(sub.planId, sub.status);
  const enabled = !!ent.features?.[feature];
  if (!enabled) throw new FeatureGateError(feature);
}

export async function isFeatureEnabledForTenant(tenantId: string, feature: FeatureKey): Promise<boolean> {
  try {
    await assertFeatureForTenant(tenantId, feature);
    return true;
  } catch {
    return false;
  }
}
