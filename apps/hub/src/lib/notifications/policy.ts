/**
 * Phase 36 — Notifications policy guard
 * Stub-only. Deterministic. No secrets printed.
 */
export class NotificationsPolicyError extends Error {
  code: 'NOTIFICATIONS_PROVIDER_NOT_STUB';
  constructor(code: NotificationsPolicyError['code']) {
    super(code);
    this.code = code;
  }
}

export function assertNotificationsProviderIsStub(providerName: string | null | undefined): void {
  const p = (providerName ?? 'stub').toLowerCase();
  if (p !== 'stub') throw new NotificationsPolicyError('NOTIFICATIONS_PROVIDER_NOT_STUB');
}
