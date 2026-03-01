import type { BillingProvider } from './types';
import { billingStubProvider } from './stub';

export function getBillingProvider(): BillingProvider {
  // Stub-only baseline. Future phases may switch based on SSOT policy.
  return billingStubProvider;
}
