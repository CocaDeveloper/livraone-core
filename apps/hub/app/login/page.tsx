"use client";

import { useEffect, useState } from "react";
import { signIn } from "next-auth/react";

export default function Login() {
  const [started, setStarted] = useState(false);

  useEffect(() => {
    if (started) return;
    setStarted(true);
    // deterministic: always go via Keycloak, return to /post-auth
    signIn("keycloak", { callbackUrl: "/post-auth" });
  }, [started]);

  return (
    <main className="min-h-screen flex items-center justify-center">
      <div className="w-full max-w-md rounded-2xl border p-6">
        <h1 className="text-xl font-semibold">Signing you in…</h1>
        <p className="mt-2 text-sm opacity-80">Redirecting to LivraOne SSO.</p>
        <button
          className="mt-6 w-full rounded-xl border px-4 py-3 text-sm"
          onClick={() => signIn("keycloak", { callbackUrl: "/post-auth" })}
        >
          Continue with Keycloak
        </button>
      </div>
    </main>
  );
}
