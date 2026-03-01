// Stripe Billing Provider (FLAG-CONTROLLED)
// Requirements:
//  - MUST NOT import Stripe at top-level.
//  - MUST NOT require Stripe secrets unless STRIPE_ENABLED=1.
//  - Uses lazy import to avoid unsafe initialization.

export type StripeConfig = {
  enabled: boolean;
  secretKey?: string;
  webhookSecret?: string;
};

function envBool(v: string | undefined): boolean {
  if (!v) return false;
  return v === "1" || v.toLowerCase() === "true" || v.toLowerCase() === "yes";
}

export function getStripeConfigFromEnv(env: NodeJS.ProcessEnv): StripeConfig {
  const enabled = envBool(env.STRIPE_ENABLED);
  if (!enabled) return { enabled: false };

  return {
    enabled: true,
    secretKey: env.STRIPE_SECRET_KEY,
    webhookSecret: env.STRIPE_WEBHOOK_SECRET,
  };
}

export async function getStripeClientOrThrow(cfg: StripeConfig): Promise<any> {
  if (!cfg.enabled) {
    throw new Error("stripe_disabled");
  }
  if (!cfg.secretKey) {
    throw new Error("missing_STRIPE_SECRET_KEY");
  }

  // LAZY IMPORT: never at top-level
  const mod: any = await import("stripe");
  const StripeCtor = mod?.default ?? mod;
  return new StripeCtor(cfg.secretKey, { apiVersion: "2024-06-20" });
}
