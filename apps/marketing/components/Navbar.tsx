export default function Navbar() {
  return (
    <header className="sticky top-0 z-20 border-b border-slate-900/10 bg-white/80 backdrop-blur">
      <div className="container-x">
        <div className="flex h-16 items-center justify-between">
          <a href="/" className="flex items-center gap-2 font-semibold text-slate-900">
            <span className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-brand-600 text-white">L</span>
            <span className="tracking-tight">LIVRAONE</span>
          </a>

          <nav className="hidden items-center gap-8 text-sm text-slate-700 md:flex">
            <a className="hover:text-slate-900" href="#features">Features</a>
            <a className="hover:text-slate-900" href="/pricing">Pricing</a>
            <a className="hover:text-slate-900" href="#testimonials">Testimonials</a>
            <a className="hover:text-slate-900" href="https://hub.livraone.com/login">Login</a>
          </nav>

          <a
            href="https://hub.livraone.com/login"
            className="inline-flex items-center justify-center rounded-md bg-grass-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-grass-700"
          >
            Get Started Free
          </a>
        </div>
      </div>
    </header>
  );
}
