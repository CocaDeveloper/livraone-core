/**
 * Phase 36 — Notifications contract (stub-only)
 * No live email/sms providers until SSOT keys exist and policy is changed in a later phase.
 */

export type NotificationChannel = 'email' | 'sms' | 'inapp';

export type NotificationRecipient = {
  userId?: string;      // preferred
  email?: string;       // optional (stub)
  phoneE164?: string;   // optional (stub)
};

export type NotificationMessage = {
  id?: string;                // optional caller id
  tenantId: string;
  channel: NotificationChannel;
  recipient: NotificationRecipient;
  template: string;           // template key (do not embed provider specifics)
  data?: Record<string, any>; // template variables
  createdAt?: string;         // ISO
};

export type DispatchResult = {
  ok: boolean;
  id: string;
  channel: NotificationChannel;
  queuedAt: string;           // ISO
  provider: 'stub';
};
