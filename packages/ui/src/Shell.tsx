import * as React from "react";
import { Card } from "./Card";

type DivProps = React.HTMLAttributes<HTMLDivElement>;

export function Page({ className = "", ...props }: DivProps) {
  return (
    <main className={`min-h-screen w-full p-6 ${className}`} {...props} />
  );
}

export function Center({ className = "", ...props }: DivProps) {
  return (
    <div className={`min-h-screen flex items-center justify-center p-6 ${className}`} {...props} />
  );
}

export function Panel({ className = "", ...props }: DivProps) {
  return (
    <Page>
      <div className={`mx-auto w-full max-w-6xl ${className}`} {...props} />
    </Page>
  );
}

export function SurfaceCard({ className = "", ...props }: DivProps) {
  return <Card className={`p-6 ${className}`} {...props} />;
}

export function AuthShell({ children }: { children: React.ReactNode }) {
  return (
    <Center>
      <SurfaceCard className="w-full max-w-md">{children}</SurfaceCard>
    </Center>
  );
}
