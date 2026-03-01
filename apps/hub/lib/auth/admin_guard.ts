import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth"; // adjust if your repo uses a different path

export async function requireAdminOrMasterEmail() {
  const session = await getServerSession(authOptions as any);
  if (!session || !(session as any).user) {
    return new Response("Unauthorized", { status: 401 });
  }

  const user: any = (session as any).user;
  const email = (user.email || "").toLowerCase();

  const isMaster = email === "master@livraone.com";
  const isAdmin =
    user.role === "admin" ||
    user.isAdmin === true ||
    (Array.isArray(user.roles) && user.roles.includes("admin"));

  if (!isMaster && !isAdmin) {
    return new Response("Forbidden", { status: 403 });
  }

  return null;
}
