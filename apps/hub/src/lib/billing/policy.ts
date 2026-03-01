/**
 * Phase 35 — Billing provider policy guard
 * Stub-only. Deterministic. No secrets printed.
 */

export class BillingPolicyError extends Error {
  code: 'BILLING_PROVIDER_NOT_STUB' | 'BILLING_KEYS_PRESENT';
  constructor(code: BillingPolicyError['code']) {
    super(code);
    this.code = code;
  }
}

export function assertBillingProviderIsStub(providerName: string | null | undefined): void {
  const p = (providerName ?? 'stub').toLowerCase();
  if (p !== 'stub') throw new BillingPolicyError('BILLING_PROVIDER_NOT_STUB');
}
