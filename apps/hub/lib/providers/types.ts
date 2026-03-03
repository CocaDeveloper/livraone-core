export type ProviderMode = "stub" | "live";

export type EmailProviderName = "stub" | "ses" | "postmark";
export type SmsProviderName = "stub" | "twilio";
export type BillingProviderName = "stub" | "stripe";

export interface EmailSendInput {
  to: string;
  subject: string;
  text?: string;
  html?: string;
}

export interface SmsSendInput {
  to: string;
  body: string;
}

export interface BillingCreateCheckoutInput {
  tenantId: string;
  plan: "basic" | "pro";
  successUrl: string;
  cancelUrl: string;
}

export interface BillingWebhookInput {
  rawBody: string;
  signature: string | null;
}

export interface EmailProvider {
  name: EmailProviderName;
  send(input: EmailSendInput): Promise<{ id: string }>;
}

export interface SmsProvider {
  name: SmsProviderName;
  send(input: SmsSendInput): Promise<{ id: string }>;
}

export interface BillingProvider {
  name: BillingProviderName;
  createCheckout(input: BillingCreateCheckoutInput): Promise<{ checkoutUrl: string }>;
  handleWebhook(input: BillingWebhookInput): Promise<{ ok: boolean }>;
  getTenantEntitlement(tenantId: string): Promise<{ plan: "free" | "basic" | "pro"; active: boolean }>;
}
