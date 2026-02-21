import type { ReactNode } from "react";
import "./globals.css";
import HubShell from "../components/layout/HubShell";

export const metadata = {
  title: "LivraOne Hub",
  description: "Authenticated workspace for LivraOne teams"
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <HubShell>{children}</HubShell>
      </body>
    </html>
  );
}
