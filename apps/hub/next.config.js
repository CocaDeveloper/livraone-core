/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  env: {
    HUB_AUTH_ISSUER: process["env"].HUB_AUTH_ISSUER,
    HUB_AUTH_CLIENT_ID: process["env"].HUB_AUTH_CLIENT_ID,
    HUB_AUTH_CLIENT_SECRET: process["env"].HUB_AUTH_CLIENT_SECRET,
    HUB_AUTH_CALLBACK_URL: process["env"].HUB_AUTH_CALLBACK_URL
  }
};

export default nextConfig;
