import type { EmailProvider, SmsProvider, BillingProvider, EmailProviderName, SmsProviderName, BillingProviderName } from "./types";
import { StubEmailProvider, StubSmsProvider, StubBillingProvider } from "./stub";

// Deterministic selection by env names.
// SSOT-only: env is loaded from /etc/livraone/hub.env by runner.
export function getEmailProvider(): EmailProvider {
  const name = (process.env.EMAIL_PROVIDER || "stub") as EmailProviderName;
  if (name === "stub") return StubEmailProvider;
  // live providers intentionally not implemented yet (Phase later)
  throw new Error("Email provider live mode not implemented; set EMAIL_PROVIDER=stub");
}

export function getSmsProvider(): SmsProvider {
  const name = (process.env.SMS_PROVIDER || "stub") as SmsProviderName;
  if (name === "stub") return StubSmsProvider;
  throw new Error("SMS provider live mode not implemented; set SMS_PROVIDER=stub");
}

export function getBillingProvider(): BillingProvider {
  const name = (process.env.BILLING_PROVIDER || "stub") as BillingProviderName;
  if (name === "stub") return StubBillingProvider;
  throw new Error("Billing provider live mode not implemented; set BILLING_PROVIDER=stub");
}
