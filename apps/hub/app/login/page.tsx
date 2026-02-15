"use client";

import { signIn } from "next-auth/react";

export default function LoginPage() {
  return (
    <section>
      <h1>Sign in</h1>
      <p>Use your organization identity to access the hub.</p>
      <button onClick={() => signIn("keycloak")}>Continue with Keycloak</button>
    </section>
  );
}
