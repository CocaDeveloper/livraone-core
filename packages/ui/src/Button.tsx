import * as React from "react";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "ghost";
};

export function Button({ className = "", variant = "primary", ...props }: Props) {
  const base = "inline-flex items-center justify-center rounded-2xl px-4 py-3 text-sm font-medium transition border";
  const v =
    variant === "primary"
      ? "bg-primary text-primaryfg border-transparent hover:opacity-90"
      : "bg-transparent text-fg border-border hover:bg-muted";
  return <button className={`${base} ${v} ${className}`} {...props} />;
}
