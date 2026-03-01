import * as React from "react";

export function Card({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={`rounded-2xl border border-border bg-card text-cardfg shadow-soft ${className}`} {...props} />;
}
