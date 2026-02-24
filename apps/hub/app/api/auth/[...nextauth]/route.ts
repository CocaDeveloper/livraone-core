import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";
import { getOnboardingCompletion } from "../../../../lib/onboarding";

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
  callbacks: {
    async jwt({ token }) {
      if (token?.sub && typeof token.onboardingComplete === "undefined") {
        const completion = await getOnboardingCompletion(token.sub);
        token.onboardingComplete = completion?.completed ?? false;
      }
      token.onboardingComplete = token.onboardingComplete ?? false;
      return token;
    },
    async session({ session, token }) {
      if (session) {
        return {
          ...session,
          onboardingComplete: token?.onboardingComplete ?? false
        };
      }
      return session;
    }
  }
});

export { handler as GET, handler as POST };
