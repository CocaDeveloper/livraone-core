import KeycloakProvider from "next-auth/providers/keycloak";

const requiredEnv = [
  "HUB_AUTH_ISSUER",
  "HUB_AUTH_CLIENT_ID",
  "HUB_AUTH_CLIENT_SECRET",
  "NEXTAUTH_SECRET",
];

for (const key of requiredEnv) {
  if (!process.env[key]) {
    throw new Error(`Missing required env ${key}`);
  }
}

const issuer = process.env.HUB_AUTH_ISSUER;
if (issuer !== "https://auth.livraone.com/realms/livraone") {
  throw new Error(
    `HUB_AUTH_ISSUER must be https://auth.livraone.com/realms/livraone, got ${issuer}`
  );
}

export const authOptions = {
  providers: [
    KeycloakProvider({
      clientId: process.env.HUB_AUTH_CLIENT_ID,
      clientSecret: process.env.HUB_AUTH_CLIENT_SECRET,
      issuer,
    }),
  ],
  session: { strategy: "jwt" },
  secret: process.env.NEXTAUTH_SECRET,
};
