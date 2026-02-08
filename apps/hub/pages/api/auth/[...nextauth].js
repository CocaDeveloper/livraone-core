import NextAuthImport from "next-auth";
const NextAuth = NextAuthImport?.default ?? NextAuthImport;
import { authOptions as importedAuthOptions } from "../../../lib/auth.js";

export const authOptions = importedAuthOptions;
export default NextAuth(authOptions);
