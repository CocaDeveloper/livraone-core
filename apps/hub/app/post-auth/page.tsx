import { redirect } from "next/navigation";
import { getServerSession } from "next-auth";
import { ensureTenantAndEntitlements } from "../../lib/entitlements";

export default async function PostAuth() {
  const session = await getServerSession();
  const userId = (session as any)?.user?.id || (session as any)?.user?.sub;

  if (!userId) redirect("/login");

  const res = await ensureTenantAndEntitlements(String(userId));
  redirect(res.redirectTo);
}
