const requiredEnv = [
  "HUB_AUTH_ISSUER",
  "HUB_AUTH_CLIENT_ID",
  "HUB_AUTH_CLIENT_SECRET",
  "HUB_AUTH_CALLBACK_URL"
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

export const authConfig = {
  issuer,
  clientId: process.env.HUB_AUTH_CLIENT_ID,
  clientSecret: process.env.HUB_AUTH_CLIENT_SECRET,
  callbackUrl: process.env.HUB_AUTH_CALLBACK_URL
};

import KeycloakProvider from "next-auth/providers/keycloak";

export const authOptions = {
  providers: [
    KeycloakProvider({
      clientId: authConfig.clientId,
      clientSecret: authConfig.clientSecret,
      issuer: authConfig.issuer,
      client: { id: authConfig.clientId, secret: authConfig.clientSecret }
    })
  ],
  callbacks: {
    async jwt({ token, account, profile }) {
      if (profile?.realm_access?.roles) {
        token.realm_access = profile.realm_access;
      }
      return token;
    },
    async session({ session, token }) {
      session.realm_access = token.realm_access ?? session.realm_access;
      return session;
    }
  },
  session: {
    strategy: "jwt"
  },
  secret: process.env.NEXTAUTH_SECRET
};
