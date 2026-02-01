import NextAuth from "next-auth";
import { authOptions } from "../../../lib/auth.js";

const handler = NextAuth(authOptions);

export default handler;
