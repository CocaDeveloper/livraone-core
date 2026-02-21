import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";

const handler = NextAuth({
  providers: [
    KeycloakProvider({
      clientId: process.env.HUB_AUTH_CLIENT_ID ?? "",
      clientSecret: process.env.HUB_AUTH_CLIENT_SECRET ?? "",
      issuer: process.env.HUB_AUTH_ISSUER ?? ""
    })
  ],
  secret: process.env.NEXTAUTH_SECRET,
  session: { strategy: "jwt" }
});

export { handler as GET, handler as POST };
