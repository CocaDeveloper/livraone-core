import type { AuditEvent } from './types';

function stableId(prefix: string, seed: string): string {
  let h = 2166136261;
  for (let i = 0; i < seed.length; i++) h = (h ^ seed.charCodeAt(i)) * 16777619;
  return `${prefix}_${(h >>> 0).toString(16)}`;
}

/**
 * Append-only in-memory store.
 * No mutation, no delete, no update APIs exposed.
 */
const AUDIT_LOG: AuditEvent[] = [];

// DEPRECATED STUB
export function appendAudit(event: Omit<AuditEvent, 'id' | 'createdAt'>): AuditEvent {
  const createdAt = new Date().toISOString();
  const seed = JSON.stringify({ ...event, createdAt });
  const id = stableId('audit', seed);

  const full: AuditEvent = {
    id,
    createdAt,
    ...event,
  };

  AUDIT_LOG.push(full);
  return full;
}

export function listAudit(): AuditEvent[] {
  return [...AUDIT_LOG];
}
