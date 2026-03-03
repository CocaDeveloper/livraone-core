import { prisma } from '@/lib/prisma';
import { getOrInitSubscription } from '@/lib/subscription';

function planMaxSeats(planId: string): number {
  switch (planId) {
    case 'free': return 1;
    case 'pro': return 5;
    case 'enterprise': return 1000;
    default: return 1;
  }
}

export async function assertSeatAvailable(tenantId: string): Promise<void> {
  const sub = await getOrInitSubscription(tenantId);
  const maxSeats = planMaxSeats(sub.planId);

  const count = await prisma.membership.count({
    where: { tenantId }
  });

  if (count >= maxSeats) {
    throw new Error('SEAT_LIMIT_EXCEEDED');
  }
}
