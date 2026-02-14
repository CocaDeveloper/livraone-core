import { getServerSession } from "next-auth/next";
import { authOptions } from "../auth/[...nextauth].js";
import { hasRole } from "../../../lib/rbac.js";

export default async function handler(req, res) {
  const session = await getServerSession(req, res, authOptions);
  if (!session) {
    return res.status(401).end("unauthenticated");
  }
  if (!hasRole(session, "admin")) {
    return res.status(403).end("forbidden");
  }
  res.status(200).json({ status: "ok" });
}
