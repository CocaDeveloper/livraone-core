"use client";

import { signOut } from "next-auth/react";

export default function LogoutPage() {
  return (
    <section>
      <h1>Signing out</h1>
      <p>Sign out of the hub session.</p>
      <button onClick={() => signOut({ callbackUrl: "/login" })}>Sign out</button>
    </section>
  );
}
