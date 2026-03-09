import { redirect } from "next/navigation";
import { normalizeAuthReturnPath } from "@/lib/auth/safe-return-path";

export const dynamic = "force-dynamic";
export const revalidate = 0;

type PostAuthPageProps = {
  searchParams?: Promise<{ from?: string | string[] }> | { from?: string | string[] };
};

export default async function PostAuth({ searchParams }: PostAuthPageProps) {
  const resolved = await Promise.resolve(searchParams);
  const from = Array.isArray(resolved?.from) ? resolved?.from[0] : resolved?.from;
  redirect(normalizeAuthReturnPath(from));
}
