import * as NextAuthModule from "next-auth";
import { authOptions } from "../../../lib/auth.js";

const candidates = [
  NextAuthModule?.default,
  NextAuthModule?.NextAuth,
  NextAuthModule,
];

const NextAuthFn = candidates.find((x) => typeof x === "function");

if (!NextAuthFn) {
  const keys = NextAuthModule ? Object.keys(NextAuthModule) : [];
  throw new Error(
    `NextAuth export is not a function. keys=${keys.join(",")}`
  );
}

export default NextAuthFn(authOptions);
