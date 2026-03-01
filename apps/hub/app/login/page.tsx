"use client";

import { useEffect, useMemo, useState } from "react";
import { signIn } from "next-auth/react";
import { AuthShell, Button } from "@livraone/ui";

const FALLBACK_MS = 2500;

export default function Login() {
  const [showFallback, setShowFallback] = useState(false);

  const start = useMemo(() => {
    return () => signIn("keycloak", { callbackUrl: "/post-auth" });
  }, []);

  useEffect(() => {
    // Start immediately
    start();

    // Only show fallback CTA if redirect didn't happen quickly
    const t = setTimeout(() => setShowFallback(true), FALLBACK_MS);
    return () => clearTimeout(t);
  }, [start]);

  return (
    <AuthShell>
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
