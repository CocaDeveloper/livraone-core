export default function OnboardingPage() {
  return (
    <div className="min-h-screen bg-slate-950 text-white">
      <div className="mx-auto flex min-h-screen max-w-3xl flex-col items-center justify-center gap-6 px-4 text-center">
        <h1 className="text-4xl font-semibold">Almost there!</h1>
        <p className="text-lg text-slate-300">
          We are verifying your onboarding steps before granting full access to the LivraOne Hub.
          Please wait a moment while our team completes your setup. If you believe this is an error,
          reach out to the onboarding team.
        </p>
        <div className="text-sm text-slate-400">
          You will be redirected to the main hub once onboarding is marked complete.
        </div>
      </div>
    </div>
  );
}
