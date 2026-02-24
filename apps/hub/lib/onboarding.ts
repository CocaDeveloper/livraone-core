import { prisma } from "./prisma";

export async function getOnboardingCompletion(userId: string) {
  return prisma.onboardingCompletion.findUnique({
    where: { userId }
  });
}
