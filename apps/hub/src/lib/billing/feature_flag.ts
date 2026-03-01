export function billingProviderEnabled(): boolean {
  const raw = process.env.BILLING_PROVIDER_ENABLED;
  return raw === 'true';
}
