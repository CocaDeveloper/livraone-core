import { prisma } from '@/lib/prisma';
import type { Subscription, PlanId, SubscriptionStatus } from './types';
import { appendAudit } from '../audit';

function toDomain(row: any): Subscription {
  return {
    tenantId: row.tenantId,
    planId: row.planId,
    status: row.status,
    currentPeriodEnd: row.currentPeriodEnd?.toISOString(),
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

export async function getOrInitSubscription(tenantId: string): Promise<Subscription> {
  let row = await prisma.subscription.findUnique({ where: { tenantId } });

  if (!row) {
    row = await prisma.subscription.create({
      data: {
        tenantId,
        planId: 'free',
        status: 'trialing',
      },
    });

    appendAudit({
      tenantId,
      type: 'subscription.updated',
      payload: { planId: 'free', status: 'trialing' },
    });
  }

  return toDomain(row);
}

export async function setSubscription(
  tenantId: string,
  planId: PlanId,
  status: SubscriptionStatus
): Promise<Subscription> {
  const row = await prisma.subscription.upsert({
    where: { tenantId },
    update: { planId, status },
    create: { tenantId, planId, status },
  });

  appendAudit({
    tenantId,
    type: 'subscription.updated',
    payload: { planId, status },
  });

  return toDomain(row);
}
