import React from "react";

function Stat({ label, value, tone }: { label: string; value: string; tone: "blue" | "green" | "amber" | "slate" }) {
  const toneCls =
    tone === "blue"
      ? "bg-gradient-to-b from-blue-500 to-blue-600"
      : tone === "green"
        ? "bg-gradient-to-b from-green-500 to-green-600"
        : tone === "amber"
          ? "bg-gradient-to-b from-amber-500 to-amber-600"
          : "bg-gradient-to-b from-slate-500 to-slate-600";

  return (
    <div className={`rounded-xl p-4 text-white shadow-card ${toneCls}`}>
      <p className="text-2xl font-extrabold leading-none">{value}</p>
      <p className="mt-1 text-xs font-semibold opacity-95">{label}</p>
    </div>
  );
}

function PanelCard({ title, right, children }: { title: string; right?: string; children: React.ReactNode }) {
  return (
    <section className="rounded-xl border border-slate-900/10 bg-white p-4 shadow-card">
      <header className="flex items-center justify-between">
        <h2 className="text-sm font-extrabold text-slate-900">{title}</h2>
        {right ? (
          <a className="text-xs font-semibold text-brand-700 hover:underline" href="#">
            {right}
          </a>
        ) : null}
      </header>
      <div className="mt-3">{children}</div>
    </section>
  );
}

export default function DashboardPage() {
  return (
    <div className="container-x">
      <div className="flex flex-col gap-1">
        <h1 className="text-2xl font-extrabold tracking-tight text-slate-900">Welcome back, John!</h1>
        <p className="text-sm text-slate-600">Log in to your LivraOne account.</p>
      </div>

      <div className="mt-5 grid gap-4 md:grid-cols-4">
        <Stat label="Active Projects" value="5" tone="blue" />
        <Stat label="New Photos" value="243" tone="slate" />
        <Stat label="Outstanding Invoices" value="$18,250" tone="green" />
        <Stat label="Pending Tasks" value="12" tone="amber" />
      </div>

      <div className="mt-5 grid gap-4 lg:grid-cols-3">
        <div className="space-y-4 lg:col-span-2">
          <PanelCard title="Recent Photos">
            <div className="grid gap-3 sm:grid-cols-3">
              {Array.from({ length: 3 }).map((_, i) => (
                <div key={i} className="overflow-hidden rounded-xl border border-slate-900/10 bg-slate-50">
                  <div className="h-24 bg-slate-200" />
                  <div className="p-3">
                    <p className="text-xs font-semibold text-slate-600">Added {i === 0 ? "2h" : "2d"} ago</p>
                  </div>
                </div>
              ))}
            </div>
          </PanelCard>

          <PanelCard title="Your Active Projects" right="View All Projects">
            <div className="space-y-3">
              {[
                { name: "Miller Residence Renovation", addr: "123 Elm St, Cityville", tasks: "7 tasks", pending: "5 pending" },
                { name: "Carter House Addition", addr: "456 Maple Ave, Oakwood", tasks: "6 tasks", pending: "3 tasks" },
                { name: "Maple St. Remodel", addr: "789 Maple St, Riverside", tasks: "4 tasks", pending: "4 tasks" }
              ].map((p) => (
                <div key={p.name} className="flex items-center justify-between gap-3 rounded-xl border border-slate-900/10 bg-slate-50 px-4 py-3">
                  <div className="min-w-0">
                    <p className="truncate text-sm font-extrabold text-slate-900">{p.name}</p>
                    <p className="truncate text-xs text-slate-600">{p.addr}</p>
                    <p className="mt-1 text-xs font-semibold text-slate-600">{p.tasks}</p>
                  </div>
                  <div className="hidden items-center gap-4 text-xs font-semibold text-slate-600 md:flex">
                    <div className="text-center">
                      <div className="text-sm font-extrabold text-brand-700">{p.pending.split(" ")[0]}</div>
                      <div className="text-[11px]">{p.pending.split(" ").slice(1).join(" ")}</div>
                    </div>
                    <div className="flex -space-x-2">
                      {Array.from({ length: 4 }).map((_, i) => (
                        <div key={i} className="h-8 w-8 rounded-lg border-2 border-slate-50 bg-slate-200" />
                      ))}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </PanelCard>
        </div>

        <div className="space-y-4">
          <PanelCard title="Upcoming Tasks" right="View All">
            <ul className="space-y-2">
              {[
                { t: "Install backsplash in the kitchen", when: "Today" },
                { t: "Review estimate with Sarah", when: "Today" },
                { t: "Inspect roof installation", when: "Today" },
                { t: "Follow up with client about invoice", when: "Today" }
              ].map((x) => (
                <li key={x.t} className="flex items-start justify-between gap-3 rounded-lg bg-slate-50 px-3 py-2">
                  <p className="text-xs font-semibold text-slate-700">{x.t}</p>
                  <span className="shrink-0 text-[11px] font-extrabold text-slate-500">{x.when}</span>
                </li>
              ))}
            </ul>
          </PanelCard>

          <PanelCard title="Financial Summary">
            <div className="space-y-2 text-xs">
              {[
                { k: "Sent Invoices", v: "$32,000" },
                { k: "Payments Collected", v: "$24,750" },
                { k: "Pending Estimates", v: "$14,500" }
              ].map((r) => (
                <div key={r.k} className="flex items-center justify-between">
                  <span className="text-slate-600">{r.k}</span>
                  <span className="font-extrabold text-slate-900">{r.v}</span>
                </div>
              ))}
            </div>
            <div className="mt-4 h-24 rounded-xl bg-slate-100" />
            <div className="mt-2 flex items-center justify-between text-[11px] font-semibold text-slate-500">
              <span>Unpaid</span>
              <span>Paid</span>
              <span>Estimate</span>
            </div>
          </PanelCard>
        </div>
      </div>
    </div>
  );
}
