import type { NotificationMessage, DispatchResult } from './types';

function stableId(prefix: string, seed: string): string {
  // Deterministic, no crypto dependency.
  let h = 2166136261;
  for (let i = 0; i < seed.length; i++) h = (h ^ seed.charCodeAt(i)) * 16777619;
  return `${prefix}_${(h >>> 0).toString(16)}`;
}

/**
 * In-memory outbox (process lifetime). Deterministic + zero IO/network.
 * Future phase may persist to DB once schema is defined.
 */
const OUTBOX: Array<{ msg: NotificationMessage; res: DispatchResult }> = [];

export function enqueueStub(msg: NotificationMessage): DispatchResult {
  const createdAt = msg.createdAt ?? new Date().toISOString();
  const seed = JSON.stringify({
    tenantId: msg.tenantId,
    channel: msg.channel,
    recipient: msg.recipient,
    template: msg.template,
    data: msg.data ?? {},
    createdAt,
  });

  const id = msg.id ?? stableId('ntf', seed);
  const res: DispatchResult = {
    ok: true,
    id,
    channel: msg.channel,
    queuedAt: new Date().toISOString(),
    provider: 'stub',
  };

  OUTBOX.push({ msg: { ...msg, id, createdAt }, res });
  return res;
}

export function listOutbox(): Array<{ msg: NotificationMessage; res: DispatchResult }> {
  return [...OUTBOX];
}

export function clearOutbox(): void {
  OUTBOX.length = 0;
}
