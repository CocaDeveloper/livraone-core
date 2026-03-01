import { prisma } from '@/lib/prisma';
import { appendAudit } from '@/lib/audit';

function now(): Date {
  return new Date();
}

export async function evaluateTrial(tenantId: string) {
  const sub = await prisma.subscription.findUnique({
    where: { tenantId },
  });

  if (!sub) return null;
  if (!sub.currentPeriodEnd) return sub;

  if (sub.status === 'trialing' && sub.currentPeriodEnd < now()) {
    const updated = await prisma.subscription.update({
      where: { tenantId },
      data: {
        planId: 'free',
        status: 'expired',
      },
    });

    await appendAudit({
      tenantId,
      type: 'subscription.updated',
      payload: {
        fromStatus: 'trialing',
        toStatus: 'expired',
        downgradedTo: 'free',
      },
    });

    return updated;
  }

  return sub;
}
