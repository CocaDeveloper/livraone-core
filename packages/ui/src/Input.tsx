import * as React from "react";

export function Input({ className = "", ...props }: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={`w-full rounded-2xl bg-card text-cardfg border border-border px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-ring ${className}`}
      {...props}
    />
  );
}
