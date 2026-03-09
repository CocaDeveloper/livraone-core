import { redirect } from "next/navigation";
import LoginPageClient from "./LoginPageClient";
import { buildAuthStartPath } from "@/lib/auth/safe-return-path";

export const dynamic = "force-dynamic";
export const revalidate = 0;

type LoginPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>> | Record<string, string | string[] | undefined>;
};

function first(value?: string | string[]) {
  return Array.isArray(value) ? value[0] : value;
}

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const resolved = await Promise.resolve(searchParams);
  const startPath = buildAuthStartPath({
    entry: first(resolved?.entry),
    from: first(resolved?.from),
    loginHint: first(resolved?.loginHint)
  });

  if (first(resolved?.manual) === "1") {
    return <LoginPageClient startPath={startPath} />;
  }

  redirect(startPath);
}
