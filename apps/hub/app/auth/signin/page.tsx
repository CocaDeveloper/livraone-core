"use client";

import { signIn } from "next-auth/react";
import { Card, Button } from "@livraone/ui";

export default function SignIn() {
  return (
    <main className="min-h-screen flex items-center justify-center p-6">
      <Card className="w-full max-w-md p-6">
        <h1 className="text-xl font-semibold">Sign in</h1>
        <p className="mt-2 text-sm text-mutedfg">Continue with LivraOne SSO.</p>
        <div className="mt-6">
          <Button className="w-full" onClick={() => signIn("keycloak", { callbackUrl: "/post-auth" })}>
            Sign in with Keycloak
          </Button>
        </div>
      </Card>
    </main>
  );
}
