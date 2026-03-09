const HUB_LOGIN_URL = "https://hub.livraone.com/api/auth/start/keycloak";

export const dynamic = "force-dynamic";
export const revalidate = 0;

export default function MarketingLoginPage() {
  return (
    <div className="relative min-h-screen overflow-hidden bg-slate-950 text-white">
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute left-1/2 top-[-220px] h-[520px] w-[780px] -translate-x-1/2 rounded-full bg-emerald-500/20 blur-3xl" />
        <div className="absolute bottom-[-200px] left-[-120px] h-[520px] w-[520px] rounded-full bg-indigo-500/20 blur-3xl" />
        <div className="absolute bottom-[-140px] right-[-120px] h-[520px] w-[520px] rounded-full bg-sky-500/10 blur-3xl" />
      </div>

      <div className="relative mx-auto flex min-h-screen max-w-5xl items-center justify-center px-4 py-12">
        <div className="w-full max-w-sm">
          <div className="mb-6 flex items-center justify-center gap-2">
            <span className="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-400 text-slate-950 shadow-sm">L</span>
            <span className="text-lg font-extrabold tracking-tight">LIVRAONE</span>
          </div>

          <div className="rounded-2xl border border-white/10 bg-slate-900/70 p-6 shadow-2xl">
            <h1 className="text-center text-xl font-extrabold">Welcome back</h1>
            <p className="mt-1 text-center text-sm text-slate-300">Sign in to manage your projects, invoices, and photos.</p>

            <form className="mt-6 space-y-4" action={HUB_LOGIN_URL} method="get">
              <label className="block text-sm font-semibold text-slate-200">
                Email
                <input
                  className="mt-2 w-full rounded-md border border-white/10 bg-slate-900/80 px-3 py-2.5 text-sm text-white placeholder:text-slate-500 focus:border-emerald-400 focus:outline-none focus:ring-1 focus:ring-emerald-400"
                  placeholder="you@company.com"
                  type="email"
                  autoComplete="username"
                  name="loginHint"
                  required
                />
              </label>

              <input type="hidden" name="entry" value="marketing" />
              <input type="hidden" name="from" value="/dashboard" />

              <p className="rounded-md bg-white/5 px-3 py-2 text-xs text-slate-300">
                You&apos;ll enter your password on the secure LivraOne SSO page.
              </p>

              <button
                type="submit"
                className="inline-flex w-full items-center justify-center rounded-md bg-emerald-400 px-4 py-2.5 text-sm font-extrabold text-slate-950 shadow-sm hover:bg-emerald-300"
              >
                Continue to sign in
              </button>
            </form>

            <p className="pt-4 text-center text-xs text-slate-300">
              Don&apos;t have an account?{" "}
              <a className="font-semibold text-emerald-300 hover:underline" href="/register">
                Start free trial
              </a>
            </p>
          </div>

          <div className="mt-8 text-center text-xs text-slate-400">© {new Date().getFullYear()} LivraOne. All rights reserved.</div>
        </div>
      </div>
    </div>
  );
}
