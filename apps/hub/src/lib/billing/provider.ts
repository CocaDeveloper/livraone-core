import { billingProviderEnabled } from './feature_flag';

export async function createCheckoutSession(): Promise<string> {
  if (!billingProviderEnabled()) {
    throw new Error('BILLING_PROVIDER_DISABLED');
  }

  // Guardrail: no SDK imported
  throw new Error('LIVE_PROVIDER_NOT_IMPLEMENTED');
}

export async function handleWebhook(_payload: any): Promise<void> {
  if (!billingProviderEnabled()) {
    throw new Error('BILLING_PROVIDER_DISABLED');
  }

  throw new Error('LIVE_PROVIDER_NOT_IMPLEMENTED');
}
