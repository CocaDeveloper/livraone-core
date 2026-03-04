import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";

const nextAuthBaseUrl = process.env.NEXTAUTH_URL ?? "https://hub.livraone.com";
let cookieDomain = "hub.livraone.com";
try {
  cookieDomain = new URL(nextAuthBaseUrl).hostname || cookieDomain;
} catch (_e) {}

const cookieBaseOptions = {
  httpOnly: true,
  sameSite: "lax" as const,
  path: "/",
  secure: true,
  domain: cookieDomain
};

const handler = NextAuth({
  providers: [
    KeycloakProvider({
      clientId: process.env.HUB_AUTH_CLIENT_ID ?? "",
      clientSecret: process.env.HUB_AUTH_CLIENT_SECRET ?? "",
      issuer: process.env.HUB_AUTH_ISSUER ?? ""
    })
  ],
  secret: process.env.NEXTAUTH_SECRET,
  session: { strategy: "jwt" },
  useSecureCookies: true,
  cookies: {
    sessionToken: {
      name: "__Secure-next-auth.session-token",
      options: { ...cookieBaseOptions }
    },
    callbackUrl: {
      name: "__Secure-next-auth.callback-url",
      options: { ...cookieBaseOptions, httpOnly: false }
    },
    csrfToken: {
      name: "__Secure-next-auth.csrf-token",
      options: { ...cookieBaseOptions, httpOnly: false }
    },
    pkceCodeVerifier: {
      name: "__Secure-next-auth.pkce.code_verifier",
      options: { ...cookieBaseOptions, sameSite: "none" as const }
    },
    state: {
      name: "__Secure-next-auth.state",
      options: { ...cookieBaseOptions, sameSite: "none" as const }
    }
  },
  callbacks: {
    async redirect({ url, baseUrl }) {
      const safeBase = nextAuthBaseUrl || baseUrl;
      if (url.startsWith("/")) return `${safeBase}${url}`;
      if (url.startsWith(safeBase)) return url;
      return safeBase;
    }
  }
});

export { handler as GET, handler as POST };
