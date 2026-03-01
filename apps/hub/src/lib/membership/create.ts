import { prisma } from '@/lib/prisma';
import { assertSeatAvailable } from '@/lib/seats/enforcement';
import { appendAudit } from '@/lib/audit';

export async function createMembership(
  tenantId: string,
  userId: string,
  role: string
) {
  await assertSeatAvailable(tenantId);

  const row = await prisma.membership.create({
    data: { tenantId, userId, role }
  });

  await appendAudit({
    tenantId,
    actorId: userId,
    type: 'rbac.role_changed',
    payload: { role }
  });

  return row;
}
