"use client";

import { useEffect, useState } from "react";
import { Button } from "@livraone/ui";

const KEY = "livraone_theme"; // "light" | "dark"

function apply(theme: "light" | "dark") {
  const root = document.documentElement;
  if (theme === "dark") root.classList.add("dark");
  else root.classList.remove("dark");
}

export function ThemeToggle() {
  const [theme, setTheme] = useState<"light" | "dark">("light");

  useEffect(() => {
    const saved = (localStorage.getItem(KEY) as "light" | "dark" | null) ?? "light";
    setTheme(saved);
    apply(saved);
  }, []);

  const toggle = () => {
    const next = theme === "dark" ? "light" : "dark";
    setTheme(next);
    localStorage.setItem(KEY, next);
    apply(next);
  };

  return (
    <Button variant="ghost" onClick={toggle}>
      {theme === "dark" ? "Light mode" : "Dark mode"}
    </Button>
  );
}
