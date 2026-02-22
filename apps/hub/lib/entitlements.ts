import { randomUUID } from "crypto";

export type EntitlementResult = {
  tenantId: string;
  redirectTo: string;
};

async function getPrisma() {
  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    return require("./prisma").prisma;
  } catch {
    try {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      return require("./db").prisma;
    } catch {
      throw new Error("Prisma client import not found (expected ./prisma or ./db).");
    }
  }
}

function slugFromUser(userId: string) {
  return `t-${userId.replace(/[^a-zA-Z0-9]/g, "").slice(0, 8) || randomUUID().slice(0, 8)}`;
}

export async function ensureTenantAndEntitlements(userId: string): Promise<EntitlementResult> {
  const prisma = await getPrisma();

  const membership = await prisma.membership.findFirst({
    where: { userId },
    include: { tenant: true },
  });

  let tenantId: string;

  if (!membership) {
    const slug = slugFromUser(userId);
    const tenant = await prisma.tenant.create({
      data: { slug, name: `Tenant ${slug}` },
    });
    tenantId = tenant.id;

    await prisma.membership.create({
      data: { tenantId, userId, role: "owner" },
    });

    const now = new Date();
    const trialEndsAt = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000);
    await prisma.subscription.create({
      data: {
        tenantId,
        status: "TRIAL",
        plan: "trial",
        trialEndsAt,
        currentPeriodEndsAt: trialEndsAt,
      },
    });
  } else {
    tenantId = membership.tenantId;
  }

  const defaults: Array<{ key: string; value: string }> = [
    { key: "hub.access", value: "true" },
    { key: "invoice.access", value: "false" },
    { key: "build360.access", value: "false" },
  ];

  for (const e of defaults) {
    await prisma.entitlement.upsert({
      where: { tenantId_key: { tenantId, key: e.key } },
      update: {},
      create: { tenantId, key: e.key, value: e.value, source: "plan" },
    });
  }

  const sub = await prisma.subscription.findFirst({
    where: { tenantId },
    orderBy: { createdAt: "desc" },
  });

  const status = sub?.status ?? "TRIAL";
  const redirectTo = status === "TRIAL" || status === "ACTIVE" ? "/" : "/billing";

  return { tenantId, redirectTo };
}
