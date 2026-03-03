import type { NotificationMessage, DispatchResult } from './types';
import { enqueueStub } from './outbox';

/**
 * Single entrypoint for notifications.
 * Stub-only in Phase 36. No provider SDK imports.
 */
export async function dispatchNotification(msg: NotificationMessage): Promise<DispatchResult> {
  // Stub dispatch
  return enqueueStub(msg);
}
