import { AuthShell } from "@livraone/ui";
import { ThemeToggle } from "@/components/theme/ThemeToggle";
type Props = {
  startPath: string;
};

export default function LoginPageClient({ startPath }: Props) {
  return (
    <AuthShell>
      <div className="mb-4 flex justify-end"><ThemeToggle /></div>
      <h1 className="text-xl font-semibold">Signing you in…</h1>
      <p className="mt-2 text-sm text-mutedfg">Continuing to LivraOne SSO.</p>
      <div className="mt-6">
        <a
          className="inline-flex w-full items-center justify-center rounded-2xl border border-border bg-transparent px-4 py-3 text-sm font-medium text-fg transition hover:bg-muted"
          href={startPath}
        >
          Continue
        </a>
      </div>
    </AuthShell>
  );
}
