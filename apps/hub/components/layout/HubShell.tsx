"use client";

import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import HubSidebar from "../HubSidebar";
import HubTopbar from "./HubTopbar";

export default function HubShell({ children }: { children: ReactNode }) {
  const pathname = usePathname() || "/";
  const isAuthScreen = pathname === "/login";

  if (isAuthScreen) return <div className="min-h-screen">{children}</div>;

  return (
    <div className="min-h-screen">
      <div className="mx-auto flex min-h-screen max-w-[1320px]">
        <HubSidebar />
        <div className="flex min-w-0 flex-1 flex-col">
          <HubTopbar />
          <main className="min-w-0 flex-1 p-5 md:p-7">{children}</main>
        </div>
      </div>
    </div>
  );
}
