// =========================================================
// Phase 48 — Feature-level billing enforcement integration
// Default behavior: NO-OP unless BILLING_ENFORCEMENT_ENABLED=1
// Never requires Stripe secrets. This is enforcement glue only.
// =========================================================

function envBool(v: string | undefined): boolean {
  if (!v) return false;
  return v === "1" || v.toLowerCase() === "true" || v.toLowerCase() === "yes";
}

export type BillingEnforcementInput = {
  // plan identifier (stringly typed; do not redesign)
  plan?: string | null;

  // subscription context object (shape varies; we probe common fields)
  subscription?: any;
};

export type BillingEnforcementResult =
  | { ok: true }
  | { ok: false; reason: "billing_inactive" | "missing_subscription_context" };

function isBillingActiveFromSubscription(sub: any): boolean {
  if (!sub) return false;

  // common variants across implementations
  if (typeof sub.billingActive === "boolean") return sub.billingActive;
  if (typeof sub.billing_active === "boolean") return sub.billing_active;

  const status = sub.billingStatus ?? sub.billing_status ?? sub.billing ?? null;
  if (typeof status === "string") {
    const s = status.toLowerCase();
    if (s === "active" || s === "enabled" || s === "ok") return true;
    if (s === "inactive" || s === "disabled" || s === "past_due" || s === "canceled") return false;
  }

  return false;
}

// Treat these as "paid" plans (best-effort) without redesign.
// If your system already encodes paidness differently, enforcement is still flag-controlled.
function isPaidPlan(plan: string | null | undefined): boolean {
  if (!plan) return false;
  const p = plan.toLowerCase();
  if (p === "free" || p === "trial") return false;
  return true;
}

export function enforceBillingForPaidFeatureAccess(input: BillingEnforcementInput): BillingEnforcementResult {
  // OFF by default (do not change behavior unless explicitly enabled)
  if (!envBool(process.env.BILLING_ENFORCEMENT_ENABLED)) return { ok: true };

  const plan = input.plan ?? null;
  if (!isPaidPlan(plan)) return { ok: true };

  const sub = input.subscription ?? null;
  if (!sub) return { ok: false, reason: "missing_subscription_context" };

  if (!isBillingActiveFromSubscription(sub)) return { ok: false, reason: "billing_inactive" };

  return { ok: true };
}
