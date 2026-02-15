export default function Navbar() {
  const links = [
    { href: '/', label: 'Home' },
    { href: '/photos', label: 'Photos' },
    { href: '/invoice', label: 'Invoice' },
    { href: '/pricing', label: 'Pricing' }
  ];
  return (
    <header style={{
      position: 'sticky',
      top: 0,
      zIndex: 20,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0.75rem 1.5rem',
      backdropFilter: 'blur(12px)',
      background: 'rgba(255, 255, 255, 0.95)',
      borderBottom: '1px solid rgba(15, 23, 42, 0.08)'
    }}>
      <div style={{ fontWeight: 700 }}>LivraOne</div>
      <nav style={{ display: 'flex', gap: '1rem' }}>
        {links.map((link) => (
          <a key={link.href} href={link.href} style={{ textDecoration: 'none', color: '#0f172a' }}>
            {link.label}
          </a>
        ))}
      </nav>
    </header>
  );
}
