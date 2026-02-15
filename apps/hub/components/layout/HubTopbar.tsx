export default function HubTopbar() {
  return (
    <header className="sticky top-0 z-20 border-b border-slate-900/10 bg-white/70 backdrop-blur">
      <div className="flex h-14 items-center justify-between px-5 md:px-7">
        <div className="hidden items-center gap-6 text-sm font-semibold text-slate-600 md:flex">
          <a className="hover:text-slate-900" href="/dashboard">Dashboard</a>
          <a className="hover:text-slate-900" href="/photos">Photos & Reports</a>
          <a className="hover:text-slate-900" href="/invoices">Invoices</a>
          <a className="hover:text-slate-900" href="#">Estimates</a>
          <a className="hover:text-slate-900" href="#">Punch Lists</a>
        </div>
        <div className="flex items-center gap-3">
          <button className="hidden rounded-md border border-slate-900/10 bg-white px-3 py-1.5 text-sm font-semibold text-slate-700 shadow-sm hover:bg-slate-50 md:inline-flex">
            Notifications
          </button>
          <div className="h-8 w-8 rounded-full bg-slate-200" aria-label="User" />
        </div>
      </div>
    </header>
  );
}
