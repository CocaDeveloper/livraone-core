export type OnboardingStep = {
  title: string;
  description: string;
  artifacts?: string[];
};

export function getOnboardingSteps(): OnboardingStep[] {
  return [
    {
      title: "Identify stakeholders",
      description: "Document the primary contacts, their roles, and the intended outcomes for the Hub engagement.",
      artifacts: ["Stakeholder directory", "Engagement charter"]
    },
    {
      title: "Secure infrastructure",
      description: "Ensure Keycloak realms, database schemas, and TLS certificates are ready before onboarding.",
      artifacts: ["Keycloak realm dump", "TLS proofs"]
    },
    {
      title: "Confirm data contract",
      description: "Validate Prisma migrations and data privacy requirements for the onboarding workload.",
      artifacts: ["Prisma migration", "Data classification"]
    }
  ];
}

export function getOnboardingChecklist(): string[] {
  return getOnboardingSteps().map((step) => step.title);
}
