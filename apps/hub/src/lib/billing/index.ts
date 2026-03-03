import type { BillingProvider } from './types';
import { billingStubProvider } from './stub';
import { getStripeConfigFromEnv } from './stripe';

export function getBillingProvider(): BillingProvider {
  const stripeCfg = getStripeConfigFromEnv(process.env);
  if (stripeCfg.enabled) {
    throw new Error('LIVE_PROVIDER_NOT_IMPLEMENTED');
  }

  // Stub-only baseline. Future phases may switch based on SSOT policy.
  return billingStubProvider;
}
