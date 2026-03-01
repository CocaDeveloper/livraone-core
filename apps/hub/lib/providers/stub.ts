import type {
  EmailProvider, SmsProvider, BillingProvider,
  EmailSendInput, SmsSendInput, BillingCreateCheckoutInput, BillingWebhookInput
} from "./types";

// NOTE: Codex must adjust this import to the repo’s canonical prisma export.
import { prisma } from "../prisma";

function randId(prefix: string) {
  return `${prefix}_${Math.random().toString(16).slice(2)}_${Date.now()}`;
}

export const StubEmailProvider: EmailProvider = {
  name: "stub",
  async send(input: EmailSendInput) {
    const id = randId("email");
    await prisma.providerOutbox.create({
      data: {
        kind: "email",
        externalId: id,
        to: input.to,
        payloadJson: JSON.stringify(input),
      },
    });
    return { id };
  },
};

export const StubSmsProvider: SmsProvider = {
  name: "stub",
  async send(input: SmsSendInput) {
    const id = randId("sms");
    await prisma.providerOutbox.create({
      data: {
        kind: "sms",
        externalId: id,
        to: input.to,
        payloadJson: JSON.stringify(input),
      },
    });
    return { id };
  },
};

export const StubBillingProvider: BillingProvider = {
  name: "stub",
  async createCheckout(input: BillingCreateCheckoutInput) {
    // Offline fake checkout URL
    const checkoutUrl = `/billing/stub/checkout?tenantId=${encodeURIComponent(input.tenantId)}&plan=${encodeURIComponent(input.plan)}`;
    await prisma.providerOutbox.create({
      data: {
        kind: "billing",
        externalId: randId("billing_checkout"),
        to: input.tenantId,
        payloadJson: JSON.stringify(input),
      },
    });
    return { checkoutUrl };
  },
  async handleWebhook(input: BillingWebhookInput) {
    await prisma.providerOutbox.create({
      data: {
        kind: "billing_webhook",
        externalId: randId("billing_webhook"),
        to: "webhook",
        payloadJson: JSON.stringify({ hasSig: !!input.signature, rawLen: input.rawBody.length }),
      },
    });
    return { ok: true };
  },
  async getTenantEntitlement(tenantId: string) {
    // Offline: default free unless a stub entitlement exists
    const ent = await prisma.stubEntitlement.findUnique({ where: { tenantId } }).catch(() => null);
    if (!ent) return { plan: "free", active: false };
    return { plan: ent.plan as any, active: ent.active };
  },
};
