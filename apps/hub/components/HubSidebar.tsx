export default function HubSidebar() {
  const items = [
    { href: '/', label: 'Home' },
    { href: '/dashboard', label: 'Dashboard' },
    { href: '/projects', label: 'Projects' },
    { href: '/photos', label: 'Photos' },
    { href: '/invoices', label: 'Invoices' },
    { href: '/clients', label: 'Clients' },
    { href: '/settings', label: 'Settings' }
  ];
  return (
    <aside className="sidebar">
      <div style={{ fontWeight: 700, marginBottom: '1.5rem' }}>Hub</div>
      <nav>
        {items.map((item) => (
          <a key={item.href} href={item.href}>
            {item.label}
          </a>
        ))}
      </nav>
    </aside>
  );
}
