import { redirect } from "next/navigation";
import { getServerSession } from "next-auth/next";
import { authOptions } from "../../lib/auth";
import { getOnboardingCompletion } from "../../lib/onboarding";

export default async function PostAuth() {
  const session = await getServerSession(authOptions);
  const userId = session?.sub ?? session?.user?.id;
  if (userId) {
    const completion = await getOnboardingCompletion(userId);
    if (!completion?.completed) {
      redirect("/onboarding");
    }
  }
  redirect("/");
}
