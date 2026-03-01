import { prisma } from '@/lib/prisma';
import type { AuditEvent } from './types';

function toDomain(row: any): AuditEvent {
  return {
    id: row.id,
    tenantId: row.tenantId,
    actorId: row.actorId ?? undefined,
    type: row.type,
    payload: row.payload ?? undefined,
    createdAt: row.createdAt.toISOString(),
  };
}

export async function appendAudit(event: Omit<AuditEvent, 'id' | 'createdAt'>): Promise<AuditEvent> {
  const row = await prisma.auditLog.create({
    data: {
      tenantId: event.tenantId,
      actorId: event.actorId ?? null,
      type: event.type,
      payload: event.payload ?? {},
    },
  });

  return toDomain(row);
}

export async function listAudit(tenantId: string): Promise<AuditEvent[]> {
  const rows = await prisma.auditLog.findMany({
    where: { tenantId },
    orderBy: { createdAt: 'desc' },
  });

  return rows.map(toDomain);
}
