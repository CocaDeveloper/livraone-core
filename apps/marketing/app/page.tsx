function FeatureCard({ title, desc }: { title: string; desc: string }) {
  return (
    <div className="rounded-xl border border-slate-900/10 bg-white p-5 shadow-card">
      <div className="mb-3 inline-flex h-10 w-10 items-center justify-center rounded-lg bg-brand-50 text-brand-700">
        <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2">
          <path d="M4 12h16" />
          <path d="M12 4v16" />
        </svg>
      </div>
      <h3 className="text-sm font-semibold text-slate-900">{title}</h3>
      <p className="mt-1 text-sm text-slate-600">{desc}</p>
    </div>
  );
}

function Testimonial({ name, role, quote }: { name: string; role: string; quote: string }) {
  return (
    <div className="rounded-xl border border-slate-900/10 bg-white p-6 shadow-card">
      <div className="flex items-center gap-3">
        <div className="h-10 w-10 rounded-full bg-slate-200" />
        <div>
          <p className="text-sm font-semibold text-slate-900">{name}</p>
          <p className="text-xs text-slate-600">{role}</p>
        </div>
      </div>
      <p className="mt-4 text-sm leading-6 text-slate-700">“{quote}”</p>
    </div>
  );
}

export default function HomePage() {
  return (
    <div>
      <section className="relative overflow-hidden">
        <div className="container-x">
          <div className="grid items-center gap-10 py-14 md:grid-cols-2 md:py-20">
            <div>
              <p className="text-sm font-semibold text-brand-700">The All-In-One Solution</p>
              <h1 className="mt-3 text-balance text-4xl font-extrabold tracking-tight text-slate-900 md:text-5xl">
                Manage projects, photos, and invoices in one workspace.
              </h1>
              <p className="mt-4 max-w-prose text-base leading-7 text-slate-600">
                Keep construction operations organized with tools for photos, invoices, estimates, punch lists, and reports.
              </p>
              <div className="mt-6 flex flex-wrap items-center gap-3">
                <a
                  href="/register"
                  className="inline-flex items-center justify-center rounded-md bg-grass-600 px-5 py-3 text-sm font-semibold text-white shadow-soft hover:bg-grass-700"
                >
                  Try LivraOne Free
                </a>
                <a href="#features" className="text-sm font-semibold text-slate-700 hover:text-slate-900">
                  See features
                </a>
              </div>

              <div className="mt-8 grid gap-4 sm:grid-cols-2">
                <div className="flex items-start gap-3 rounded-lg bg-white/70 p-4 ring-1 ring-slate-900/10">
                  <div className="mt-0.5 inline-flex h-8 w-8 items-center justify-center rounded-lg bg-brand-50 text-brand-700">
                    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M4 7h16" />
                      <path d="M7 4v16" />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-slate-900">Capture & Organize</p>
                    <p className="text-xs text-slate-600">Easily take and organize photos.</p>
                  </div>
                </div>
                <div className="flex items-start gap-3 rounded-lg bg-white/70 p-4 ring-1 ring-slate-900/10">
                  <div className="mt-0.5 inline-flex h-8 w-8 items-center justify-center rounded-lg bg-green-50 text-green-700">
                    <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M4 19h16" />
                      <path d="M7 4h10v12H7z" />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-slate-900">Invoice & Estimate</p>
                    <p className="text-xs text-slate-600">Create professional invoices fast.</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="relative">
              <div className="absolute -right-6 -top-6 h-40 w-40 rounded-full bg-brand-200/35 blur-3xl" />
              <div className="absolute -bottom-10 left-6 h-48 w-48 rounded-full bg-sky-200/35 blur-3xl" />

              <div className="relative mx-auto max-w-md">
                <div className="rounded-2xl border border-slate-900/10 bg-white shadow-soft">
                  <div className="flex items-center justify-between border-b border-slate-900/10 px-5 py-3">
                    <div className="flex items-center gap-2">
                      <span className="h-2 w-2 rounded-full bg-red-400" />
                      <span className="h-2 w-2 rounded-full bg-amber-400" />
                      <span className="h-2 w-2 rounded-full bg-green-400" />
                    </div>
                    <p className="text-xs font-semibold text-slate-500">Dashboard</p>
                  </div>
                  <div className="p-5">
                    <div className="grid grid-cols-3 gap-3">
                      {Array.from({ length: 3 }).map((_, i) => (
                        <div key={i} className="rounded-lg bg-slate-100 p-3">
                          <div className="h-2 w-10 rounded bg-slate-300" />
                          <div className="mt-2 h-6 w-14 rounded bg-slate-200" />
                        </div>
                      ))}
                    </div>
                    <div className="mt-4 grid gap-3">
                      <div className="h-28 rounded-xl bg-slate-100" />
                      <div className="h-24 rounded-xl bg-slate-100" />
                    </div>
                  </div>
                </div>

                <div className="absolute -bottom-6 right-6 w-44 rounded-2xl border border-slate-900/10 bg-white p-3 shadow-card">
                  <div className="flex items-center justify-between">
                    <div className="h-2 w-16 rounded bg-slate-300" />
                    <div className="h-6 w-6 rounded-lg bg-green-100" />
                  </div>
                  <div className="mt-3 h-20 rounded-xl bg-slate-100" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="features" className="py-14">
        <div className="container-x">
          <h2 className="text-center text-2xl font-extrabold tracking-tight text-slate-900 md:text-3xl">
            All the tools you need in one platform
          </h2>
          <div className="mt-8 grid gap-5 md:grid-cols-2">
            <FeatureCard title="Photo Capture" desc="Snap and annotate photos to document issues." />
            <FeatureCard title="Invoicing & Estimates" desc="Create custom invoices and job estimates quickly." />
            <FeatureCard title="Punch Lists & Tasks" desc="Track tasks to ensure project completion." />
            <FeatureCard title="Reports & Progress" desc="Generate reports and track progress over time." />
          </div>
        </div>
      </section>

      <section className="py-14">
        <div className="container-x">
          <div className="grid items-center gap-10 md:grid-cols-2">
            <div>
              <h3 className="text-2xl font-extrabold tracking-tight text-slate-900">Collaborate seamlessly</h3>
              <p className="mt-3 text-sm leading-6 text-slate-600">
                Keep your team aligned with real-time updates and organized documentation.
              </p>
              <div className="mt-6 flex flex-wrap items-center gap-4 text-xs font-semibold text-slate-500">
                <span className="rounded bg-white px-3 py-2 ring-1 ring-slate-900/10">CompanyCam</span>
                <span className="rounded bg-white px-3 py-2 ring-1 ring-slate-900/10">QuickBooks</span>
                <span className="rounded bg-white px-3 py-2 ring-1 ring-slate-900/10">Xero</span>
              </div>
            </div>
            <div className="rounded-2xl border border-slate-900/10 bg-white p-5 shadow-soft">
              <div className="h-56 rounded-xl bg-slate-100" />
              <p className="mt-3 text-xs text-slate-600">Preview: shared punch lists, photos, and notes.</p>
            </div>
          </div>
        </div>
      </section>

      <section id="testimonials" className="py-14">
        <div className="container-x">
          <h3 className="text-center text-2xl font-extrabold tracking-tight text-slate-900">Trusted by professionals</h3>
          <div className="mt-8 grid gap-5 md:grid-cols-2">
            <Testimonial
              name="Mark Thompson"
              role="Thompson Builders"
              quote="LivraOne streamlined our workflow and improved communication across crews."
            />
            <Testimonial
              name="Sarah Johnson"
              role="Johnson Remodeling"
              quote="Managing estimates and invoices is faster and simpler than before."
            />
          </div>

          <div className="mt-10 flex justify-center">
            <a
              href="/register"
              className="inline-flex items-center justify-center rounded-md bg-grass-600 px-6 py-3 text-sm font-semibold text-white shadow-soft hover:bg-grass-700"
            >
              Get Started Free
            </a>
          </div>
        </div>
      </section>

      <footer className="border-t border-slate-900/10 bg-white/70 py-10">
        <div className="container-x">
          <div className="flex flex-col items-center justify-between gap-6 md:flex-row">
            <p className="text-xs text-slate-600">© {new Date().getFullYear()} LivraOne. All rights reserved.</p>
            <div className="flex items-center gap-4 text-xs text-slate-600">
              <a className="hover:text-slate-900" href="#">FAQ</a>
              <a className="hover:text-slate-900" href="#">Blog</a>
              <a className="hover:text-slate-900" href="#">Contact</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
