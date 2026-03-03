import type { Config } from "tailwindcss";

export const livraonePreset: Config = {
  theme: {
    extend: {
      borderRadius: {
        xl: "1rem",
        "2xl": "1.25rem",
      },
      boxShadow: {
        soft: "0 10px 30px rgba(0,0,0,0.18)",
      },
      colors: {
        // semantic tokens (driven by CSS vars)
        bg: "hsl(var(--bg))",
        fg: "hsl(var(--fg))",
        card: "hsl(var(--card))",
        cardfg: "hsl(var(--card-fg))",
        primary: "hsl(var(--primary))",
        primaryfg: "hsl(var(--primary-fg))",
        muted: "hsl(var(--muted))",
        mutedfg: "hsl(var(--muted-fg))",
        border: "hsl(var(--border))",
        ring: "hsl(var(--ring))",
      },
    },
  },
};
