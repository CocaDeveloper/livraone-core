const nav = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/photos", label: "Photos & Reports" },
  { href: "/invoices", label: "Invoices" },
  { href: "#", label: "Estimates" },
  { href: "#", label: "Punch Lists" },
  { href: "#", label: "Daily Logs" },
  { href: "/clients", label: "Clients" }
];

function Item({ href, label }: { href: string; label: string }) {
  return (
    <a href={href} className="group flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-100">
      <span className="inline-flex h-7 w-7 items-center justify-center rounded-md bg-slate-100 text-slate-600 group-hover:bg-white">
        <span className="h-3 w-3 rounded bg-slate-400" />
      </span>
      {label}
    </a>
  );
}

export default function HubSidebar() {
  return (
    <aside className="hidden w-[260px] shrink-0 border-r border-slate-900/10 bg-white/70 px-4 py-5 backdrop-blur md:block">
      <a href="/dashboard" className="mb-5 flex items-center gap-2">
        <span className="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-brand-600 text-white shadow-sm">L</span>
        <div>
          <div className="text-sm font-extrabold tracking-tight text-slate-900">LIVRAONE</div>
          <div className="text-xs font-semibold text-slate-500">Hub</div>
        </div>
      </a>

      <nav className="space-y-1">
        {nav.map((n) => (
          <Item key={n.label} href={n.href} label={n.label} />
        ))}
      </nav>

      <div className="mt-5">
        <a
          href="/projects"
          className="inline-flex w-full items-center justify-center rounded-md bg-grass-600 px-3 py-2 text-sm font-extrabold text-white shadow-sm hover:bg-grass-700"
        >
          + Create New
        </a>
      </div>

      <div className="mt-6 space-y-2">
        <p className="text-xs font-extrabold text-slate-500">Integrations</p>
        <div className="space-y-1 text-xs font-semibold text-slate-600">
          <div className="flex items-center gap-2 rounded-lg px-2 py-2 hover:bg-slate-50">
            <span className="h-6 w-6 rounded bg-slate-200" /> QuickBooks
          </div>
          <div className="flex items-center gap-2 rounded-lg px-2 py-2 hover:bg-slate-50">
            <span className="h-6 w-6 rounded bg-slate-200" /> Xero
          </div>
          <div className="flex items-center gap-2 rounded-lg px-2 py-2 hover:bg-slate-50">
            <span className="h-6 w-6 rounded bg-slate-200" /> Google Drive
          </div>
        </div>
      </div>

      <div className="mt-10 flex items-center gap-3 rounded-xl border border-slate-900/10 bg-white p-3 shadow-sm">
        <div className="h-10 w-10 rounded-full bg-slate-200" />
        <div className="min-w-0">
          <div className="truncate text-sm font-extrabold text-slate-900">John Anderson</div>
          <div className="text-xs font-semibold text-slate-500">john@company.com</div>
        </div>
      </div>
    </aside>
  );
}
