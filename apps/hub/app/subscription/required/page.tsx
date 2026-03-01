export default function SubscriptionRequiredPage({
  searchParams,
}: {
  searchParams?: { from?: string };
}) {
  const from = searchParams?.from ?? '';
  return (
    <main style={{ padding: 24 }}>
      <h1>Subscription required</h1>
      <p>Your subscription is not active for this tenant.</p>
      {from ? <p>Requested: <code>{from}</code></p> : null}
      <p>Go to billing to upgrade.</p>
    </main>
  );
}
