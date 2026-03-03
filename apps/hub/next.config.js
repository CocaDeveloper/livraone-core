/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@livraone/ui", "@livraone/tailwind-config"],
  experimental: {
    externalDir: true
  }
};
module.exports = nextConfig;
