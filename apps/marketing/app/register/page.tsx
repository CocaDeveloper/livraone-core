"use client";

import { useMemo, useState } from "react";

const HUB_SIGNUP_URL = "https://hub.livraone.com/login";
const STORAGE_KEY = "livraone_referral";

type ReferralOption = "Google" | "Facebook" | "Instagram" | "Friend referral" | "Other";

export default function MarketingRegisterPage() {
  const [referralSource, setReferralSource] = useState<ReferralOption | "">("");
  const [referralOtherText, setReferralOtherText] = useState("");
  const [error, setError] = useState<string | null>(null);

  const needsOther = referralSource === "Other";
  const canSubmit = useMemo(() => {
    if (!referralSource) return false;
    if (needsOther && referralOtherText.trim().length < 2) return false;
    return true;
  }, [referralSource, referralOtherText, needsOther]);

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    if (!canSubmit) {
      setError("Please select how you heard about us.");
      return;
    }

    try {
      const payload = {
        referralSource,
        referralOtherText: needsOther ? referralOtherText.trim() : "",
        ts: Date.now(),
      };
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));

      const url = new URL(HUB_SIGNUP_URL);
      url.searchParams.set("referralSource", referralSource);
      if (needsOther && referralOtherText.trim()) {
        url.searchParams.set("referralOtherText", referralOtherText.trim());
      }
      url.searchParams.set("signup", "1");
      window.location.href = url.toString();
    } catch {
      setError("Unable to continue to registration. Please try again.");
    }
  };

  return (
    <div className="relative min-h-screen overflow-hidden bg-slate-950 text-white">
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute left-1/2 top-[-220px] h-[520px] w-[780px] -translate-x-1/2 rounded-full bg-emerald-500/20 blur-3xl" />
        <div className="absolute bottom-[-200px] left-[-120px] h-[520px] w-[520px] rounded-full bg-indigo-500/20 blur-3xl" />
        <div className="absolute bottom-[-140px] right-[-120px] h-[520px] w-[520px] rounded-full bg-sky-500/10 blur-3xl" />
      </div>

      <div className="relative mx-auto flex min-h-screen max-w-5xl items-center justify-center px-4 py-12">
        <div className="w-full max-w-md">
          <div className="mb-6 flex items-center justify-center gap-2">
            <span className="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-400 text-slate-950 shadow-sm">L</span>
            <span className="text-lg font-extrabold tracking-tight">LIVRAONE</span>
          </div>

          <div className="rounded-2xl border border-white/10 bg-slate-900/70 p-6 shadow-2xl">
            <h1 className="text-center text-xl font-extrabold">Start your free trial</h1>
            <p className="mt-1 text-center text-sm text-slate-300">We&apos;ll take you to the secure signup flow in the hub.</p>

            <form className="mt-6 space-y-4" onSubmit={handleSubmit}>
              <label className="block text-sm font-semibold text-slate-200">
                Work email
                <input
                  className="mt-2 w-full rounded-md border border-white/10 bg-slate-900/80 px-3 py-2.5 text-sm text-white placeholder:text-slate-500 focus:border-emerald-400 focus:outline-none focus:ring-1 focus:ring-emerald-400"
                  placeholder="you@company.com"
                  type="email"
                  autoComplete="email"
                  required
                />
              </label>

              <label className="block text-sm font-semibold text-slate-200">
                How did you hear about us?
                <select
                  className="mt-2 w-full rounded-md border border-white/10 bg-slate-900/80 px-3 py-2.5 text-sm text-white focus:border-emerald-400 focus:outline-none focus:ring-1 focus:ring-emerald-400"
                  value={referralSource}
                  onChange={(event) => setReferralSource(event.target.value as ReferralOption)}
                  required
                >
                  <option value="" disabled>
                    Select one
                  </option>
                  <option value="Google">Google</option>
                  <option value="Facebook">Facebook</option>
                  <option value="Instagram">Instagram</option>
                  <option value="Friend referral">Friend referral</option>
                  <option value="Other">Other</option>
                </select>
              </label>

              {needsOther ? (
                <label className="block text-sm font-semibold text-slate-200">
                  Tell us more
                  <input
                    className="mt-2 w-full rounded-md border border-white/10 bg-slate-900/80 px-3 py-2.5 text-sm text-white placeholder:text-slate-500 focus:border-emerald-400 focus:outline-none focus:ring-1 focus:ring-emerald-400"
                    placeholder="Type your referral source"
                    value={referralOtherText}
                    onChange={(event) => setReferralOtherText(event.target.value)}
                    required
                  />
                </label>
              ) : null}

              {error ? <p className="rounded-md bg-red-500/10 px-3 py-2 text-xs text-red-200">{error}</p> : null}

              <button
                type="submit"
                disabled={!canSubmit}
                className="inline-flex w-full items-center justify-center rounded-md bg-emerald-400 px-4 py-2.5 text-sm font-extrabold text-slate-950 shadow-sm hover:bg-emerald-300 disabled:cursor-not-allowed disabled:opacity-60"
              >
                Continue to signup
              </button>
            </form>

            <p className="pt-4 text-center text-xs text-slate-300">
              Already have an account?{" "}
              <a className="font-semibold text-emerald-300 hover:underline" href="/login">
                Log in
              </a>
            </p>
          </div>

          <div className="mt-8 text-center text-xs text-slate-400">© {new Date().getFullYear()} LivraOne. All rights reserved.</div>
        </div>
      </div>
    </div>
  );
}
