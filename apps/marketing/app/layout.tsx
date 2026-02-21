import type { ReactNode } from 'react';
import './globals.css';
import Navbar from '../components/Navbar';

export const metadata = {
  title: 'LivraOne Marketing',
  description: 'Public landing for LivraOne'
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Navbar />
        <main>{children}</main>
      </body>
    </html>
  );
}
