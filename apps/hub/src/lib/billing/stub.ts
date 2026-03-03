import type { BillingProvider, BillingCustomer, CheckoutSession } from './types';

function stableId(prefix: string, seed: string): string {
  // Deterministic, no crypto dependency; stable across runs.
  let h = 2166136261;
  for (let i = 0; i < seed.length; i++) h = (h ^ seed.charCodeAt(i)) * 16777619;
  const hex = (h >>> 0).toString(16);
  return `${prefix}_${hex}`;
}

export const billingStubProvider: BillingProvider = {
  name: 'stub',

  async createCustomer(input: { tenantId: string }): Promise<BillingCustomer> {
    return { id: stableId('cust', input.tenantId), provider: 'stub' };
  },

  async createCheckoutSession(input): Promise<CheckoutSession> {
    // Provide a deterministic local placeholder URL (no network).
    const id = stableId('chk', `${input.tenantId}:${input.planId}:${input.successUrl}:${input.cancelUrl}`);
    return { id, url: `/billing/stub/checkout/${id}`, provider: 'stub' };
  },
};
