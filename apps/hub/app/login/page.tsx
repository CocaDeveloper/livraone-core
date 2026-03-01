"use client";

import { useEffect, useState } from "react";
import { signIn } from "next-auth/react";
import { AuthShell, Button } from "@livraone/ui";

export default function Login() {
  const [started, setStarted] = useState(false);

  useEffect(() => {
    if (started) return;
    setStarted(true);
    signIn("keycloak", { callbackUrl: "/post-auth" });
  }, [started]);

  return (
    <AuthShell>
      <h1 className="text-xl font-semibold">Signing you in…</h1>
      <p className="mt-2 text-sm text-mutedfg">Redirecting to LivraOne SSO.</p>
      <div className="mt-6">
        <Button
          className="w-full"
          variant="ghost"
          onClick={() => signIn("keycloak", { callbackUrl: "/post-auth" })}
        >
          Continue with Keycloak
        </Button>
      </div>
    </AuthShell>
  );
}
