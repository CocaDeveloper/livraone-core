import { getOnboardingSteps } from "../../lib/onboarding";

export default function OnboardingPage() {
  const steps = getOnboardingSteps();
  return (
    <section className="space-y-6 p-6">
      <h1 className="text-3xl font-bold">Onboarding contract</h1>
      <p className="text-base text-slate-600">
        The onboarding contract tracks the mandatory checkpoints for every Hub project. The gate ensures this
        reference is always available.
      </p>
      <ol className="space-y-4 list-decimal pl-6">
        {steps.map((step) => (
          <li key={step.title} className="space-y-1">
            <h2 className="text-xl font-semibold">{step.title}</h2>
            <p>{step.description}</p>
            {step.artifacts?.length ? (
              <ul className="list-disc pl-4 text-sm text-slate-500">
                {step.artifacts.map((artifact) => (
                  <li key={artifact}>{artifact}</li>
                ))}
              </ul>
            ) : null}
          </li>
        ))}
      </ol>
    </section>
  );
}
