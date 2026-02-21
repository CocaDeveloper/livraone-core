"use client";

import { signIn } from "next-auth/react";

function SocialButton({ label, variant }: { label: string; variant: "google" | "facebook" | "apple" }) {
  const cls =
    variant === "google"
      ? "bg-white text-slate-700 ring-1 ring-slate-900/10 hover:bg-slate-50"
      : variant === "facebook"
        ? "bg-[#2b5aa3] text-white hover:brightness-95"
        : "bg-slate-900 text-white hover:bg-black";

  return (
    <button
      type="button"
      onClick={() => signIn("keycloak")}
      className={`inline-flex w-full items-center justify-center gap-2 rounded-md px-4 py-2.5 text-sm font-semibold shadow-sm ${cls}`}
    >
      <span className="inline-flex h-5 w-5 items-center justify-center rounded bg-white/20">
        <span className="h-3 w-3 rounded bg-white/80" />
      </span>
      {label}
    </button>
  );
}

export default function LoginPage() {
  return (
    <div className="relative min-h-screen overflow-hidden">
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute left-1/2 top-[-180px] h-[520px] w-[760px] -translate-x-1/2 rounded-full bg-brand-200/40 blur-3xl" />
        <div className="absolute bottom-[-220px] left-[-120px] h-[520px] w-[520px] rounded-full bg-sky-200/45 blur-3xl" />
        <div className="absolute bottom-[-120px] right-[-120px] h-[520px] w-[520px] rounded-full bg-indigo-200/25 blur-3xl" />
      </div>

      <div className="relative mx-auto flex min-h-screen max-w-5xl items-center justify-center px-4 py-12">
        <div className="w-full max-w-sm">
          <div className="mb-6 flex items-center justify-center gap-2">
            <span className="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-brand-600 text-white shadow-sm">L</span>
            <span className="text-lg font-extrabold tracking-tight text-slate-900">LIVRAONE</span>
          </div>

          <div className="rounded-2xl border border-slate-900/10 bg-white/90 p-6 shadow-soft">
            <h1 className="text-center text-xl font-extrabold text-slate-900">Welcome Back</h1>
            <p className="mt-1 text-center text-sm text-slate-600">Log in to your LivraOne account.</p>

            <div className="mt-6 space-y-3">
              <label className="block">
                <span className="sr-only">Email</span>
                <div className="flex items-center gap-2 rounded-md border border-slate-900/10 bg-white px-3 py-2.5">
                  <span className="h-4 w-4 rounded bg-slate-300" />
                  <input
                    className="w-full bg-transparent text-sm outline-none placeholder:text-slate-400"
                    placeholder="Email"
                    autoComplete="email"
                  />
                </div>
              </label>

              <label className="block">
                <span className="sr-only">Password</span>
                <div className="flex items-center gap-2 rounded-md border border-slate-900/10 bg-white px-3 py-2.5">
                  <span className="h-4 w-4 rounded bg-slate-300" />
                  <input
                    className="w-full bg-transparent text-sm outline-none placeholder:text-slate-400"
                    placeholder="Password"
                    type="password"
                    autoComplete="current-password"
                  />
                  <a className="text-xs font-semibold text-grass-700 hover:underline" href="#">
                    Forgot password?
                  </a>
                </div>
              </label>

              <button
                type="button"
                onClick={() => signIn("keycloak")}
                className="mt-1 inline-flex w-full items-center justify-center rounded-md bg-grass-600 px-4 py-2.5 text-sm font-extrabold text-white shadow-sm hover:bg-grass-700"
              >
                Log In
              </button>

              <div className="flex items-center gap-3 py-2">
                <div className="h-px flex-1 bg-slate-900/10" />
                <span className="text-xs font-semibold text-slate-500">or</span>
                <div className="h-px flex-1 bg-slate-900/10" />
              </div>

              <div className="space-y-2">
                <SocialButton label="Continue with Google" variant="google" />
                <SocialButton label="Continue with Facebook" variant="facebook" />
                <SocialButton label="Continue with Apple" variant="apple" />
              </div>

              <p className="pt-2 text-center text-xs text-slate-600">
                Don&apos;t have an account?{" "}
                <a className="font-semibold text-grass-700 hover:underline" href="#">
                  Get Started Free
                </a>
              </p>
            </div>
          </div>

          <div className="mt-8 text-center text-xs text-slate-600">© {new Date().getFullYear()} LivraOne. All rights reserved.</div>
          <div className="mt-3 flex items-center justify-center gap-3 text-slate-700">
            <span className="h-6 w-6 rounded bg-slate-200" />
            <span className="h-6 w-6 rounded bg-slate-200" />
            <span className="h-6 w-6 rounded bg-slate-200" />
          </div>
        </div>

        <div className="pointer-events-none relative hidden w-[420px] md:block">
          <div className="absolute -right-6 bottom-4 h-72 w-72 rounded-3xl border border-slate-900/10 bg-white/70 shadow-card" />
          <div className="absolute right-5 bottom-10 h-28 w-28 rotate-6 rounded-3xl bg-amber-200/70" />
          <div className="absolute right-14 bottom-24 h-36 w-56 -rotate-2 rounded-3xl bg-slate-100" />
        </div>
      </div>
    </div>
  );
}
