"use client";

import { useEffect, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { signIn } from "next-auth/react";
import { AuthShell, Button } from "@livraone/ui";
import { ThemeToggle } from "@/components/theme/ThemeToggle";
import { buildPostAuthCallback } from "@/lib/auth/safe-return-path";

const FALLBACK_MS = 2500;

export default function LoginPageClient() {
  const searchParams = useSearchParams();
  const [showFallback, setShowFallback] = useState(false);

  const callbackUrl = useMemo(() => {
    return buildPostAuthCallback(searchParams.get("from"));
  }, [searchParams]);

  const loginHint = useMemo(() => {
    const value = searchParams.get("loginHint")?.trim();
    return value || undefined;
  }, [searchParams]);

  // Phase 72.8: iOS/Safari deterministic auth bootstrap.
  // Ensure NextAuth CSRF cookie is set before calling signIn.
  const start = useMemo(() => {
    return async () => {
      try {
        // credentials: include ensures the __Secure-next-auth.csrf-token cookie is persisted.
        await fetch("/api/auth/csrf", { method: "GET", credentials: "include", cache: "no-store" });
      } catch {
        // ignore; signIn will still attempt, but iOS reliability improves when CSRF cookie is present.
      }

      return signIn("keycloak", { callbackUrl }, loginHint ? { login_hint: loginHint } : undefined);
    };
  }, [callbackUrl, loginHint]);

  useEffect(() => {
    start();

    const t = setTimeout(() => setShowFallback(true), FALLBACK_MS);
    return () => clearTimeout(t);
  }, [start]);

  return (
    <AuthShell>
      <div className="mb-4 flex justify-end"><ThemeToggle /></div>
      <h1 className="text-xl font-semibold">Signing you in…</h1>
      <p className="mt-2 text-sm text-mutedfg">Redirecting to LivraOne SSO.</p>

      {showFallback ? (
        <div className="mt-6">
          <Button className="w-full" variant="ghost" onClick={start}>
            Continue
          </Button>
        </div>
      ) : null}
    </AuthShell>
  );
}
