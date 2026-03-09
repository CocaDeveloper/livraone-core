/** @type {import('next').NextConfig} */
const noStoreHeaders = [
  { key: "Cache-Control", value: "no-store, no-cache, must-revalidate, max-age=0, private" },
  { key: "Pragma", value: "no-cache" },
  { key: "Expires", value: "0" }
];

const nextConfig = {
  reactStrictMode: true,
  async headers() {
    return [
      { source: "/login", headers: noStoreHeaders },
      { source: "/register", headers: noStoreHeaders }
    ];
  }
};
module.exports = nextConfig;
