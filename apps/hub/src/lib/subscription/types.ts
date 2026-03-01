/**
 * Phase 37 — Subscription + Entitlement contract (stub-backed)
 * No live billing integration. Deterministic state handling.
 */

export type SubscriptionStatus =
  | 'trialing'
  | 'active'
  | 'past_due'
  | 'canceled'
  | 'expired';

export type PlanId = 'free' | 'starter' | 'pro' | 'enterprise';

export type Subscription = {
  tenantId: string;
  planId: PlanId;
  status: SubscriptionStatus;
  currentPeriodEnd?: string; // ISO
  createdAt: string;         // ISO
  updatedAt: string;         // ISO
};

export type Entitlements = {
  canAccessApp: boolean;     // global gate
  canInviteUsers: boolean;
  maxSeats: number;          // seat cap enforcement in future phase
  features: Record<string, boolean>;
};

export type EntitlementDecision = {
  ok: boolean;
  reason?: 'SUBSCRIPTION_REQUIRED' | 'SUBSCRIPTION_INACTIVE' | 'PLAN_RESTRICTED';
};
