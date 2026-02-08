import { authOptions } from "../../../lib/auth.js";

export { authOptions };

const NextAuthPkg = require("next-auth");
const NextAuthFn =
  (NextAuthPkg && NextAuthPkg.default) ||
  (NextAuthPkg && NextAuthPkg.NextAuth) ||
  NextAuthPkg;

if (typeof NextAuthFn !== "function") {
  const keys = NextAuthPkg ? Object.keys(NextAuthPkg) : [];
  throw new Error(
    `NextAuth export is not callable (typeof=${typeof NextAuthFn}, keys=${keys.join(
      ","
    )})`
  );
}

export default NextAuthFn(authOptions);
