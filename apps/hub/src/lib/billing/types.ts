/**
 * Phase 35 — Billing contract (stub-only)
 * No live providers until SSOT keys exist and provider policy changes in a later phase.
 */

export type BillingProviderName = 'stub';

export type Money = {
  amount: number; // minor units (e.g., cents)
  currency: string; // ISO 4217 lowercase preferred
};

export type CheckoutSessionCreateInput = {
  tenantId: string;
  planId: string;
  successUrl: string;
  cancelUrl: string;
};

export type CheckoutSession = {
  id: string;
  url: string;
  provider: BillingProviderName;
};

export type BillingCustomer = {
  id: string;
  provider: BillingProviderName;
};

export interface BillingProvider {
  name: BillingProviderName;
  createCustomer(input: { tenantId: string }): Promise<BillingCustomer>;
  createCheckoutSession(input: CheckoutSessionCreateInput): Promise<CheckoutSession>;
}
