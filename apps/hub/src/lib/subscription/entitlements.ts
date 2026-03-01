import type { Entitlements, PlanId, SubscriptionStatus } from './types';

export function entitlementsFor(planId: PlanId, status: SubscriptionStatus): Entitlements {
  const active = status === 'active' || status === 'trialing';

  // Baseline feature flags (extend later, deterministic)
  const base = {
    canAccessApp: active,
    canInviteUsers: active && planId !== 'free',
    maxSeats: planId === 'enterprise' ? 1000 : planId === 'pro' ? 50 : planId === 'starter' ? 10 : 3,
    features: {
      audit: planId !== 'free' && active,
      exports: planId !== 'free' && active,
      advanced_rbac: (planId === 'pro' || planId === 'enterprise') && active,
    },
  } satisfies Entitlements;

  return base;
}
