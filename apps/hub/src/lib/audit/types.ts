/**
 * Phase 39 — Audit log contract (append-only)
 * Deterministic, stub-backed. No network. No deletion/update operations.
 */

export type AuditEventType =
  | 'subscription.updated'
  | 'rbac.role_changed'
  | 'auth.login'
  | 'auth.logout'
  | 'system.event';

export type AuditEvent = {
  id: string;
  tenantId: string;
  actorId?: string;
  type: AuditEventType;
  payload?: Record<string, any>;
  createdAt: string; // ISO
};
