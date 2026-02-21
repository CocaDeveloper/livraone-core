import type { ReactNode } from 'react';
import './globals.css';
import HubSidebar from '../components/HubSidebar';

export const metadata = {
  title: 'LivraOne Hub',
  description: 'Authenticated workspace for LivraOne teams'
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <div className="layout">
          <HubSidebar />
          <main className="main">{children}</main>
        </div>
      </body>
    </html>
  );
}
