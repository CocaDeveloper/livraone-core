import NextAuth from "next-auth";
import { authOptions as importedAuthOptions } from "../../../lib/auth.js";

export const authOptions = importedAuthOptions;
export default NextAuth(authOptions);
