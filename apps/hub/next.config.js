/** @type {import('next').NextConfig} */
const noStoreHeaders = [
  { key: "Cache-Control", value: "no-store, no-cache, must-revalidate, max-age=0, private" },
  { key: "Pragma", value: "no-cache" },
  { key: "Expires", value: "0" },
  { key: "Vary", value: "Cookie" }
];

const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@livraone/ui", "@livraone/tailwind-config"],
  experimental: {
    externalDir: true
  },
  async headers() {
    return [
      { source: "/login", headers: noStoreHeaders },
      { source: "/auth/signin", headers: noStoreHeaders },
      { source: "/post-auth", headers: noStoreHeaders },
      { source: "/logout", headers: noStoreHeaders }
    ];
  }
};
module.exports = nextConfig;
