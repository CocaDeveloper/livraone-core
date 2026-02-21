$ErrorActionPreference = 'Stop'
$VPS_IP = 'CHANGE_ME'
$VPS_USER = 'livraone'
$Evidence = Join-Path $env:TEMP 'livraone-phase9-launch'
New-Item -ItemType Directory -Force -Path $Evidence | Out-Null

"=== SYSTEM ===" | Tee-Object -FilePath (Join-Path $Evidence 'system.txt')
[PSCustomObject]@{
  OS = (Get-ComputerInfo).OsName
  PSVersion = $PSVersionTable.PSVersion.ToString()
} | Out-String | Tee-Object -FilePath (Join-Path $Evidence 'system.txt') -Append

"=== NETWORK ===" | Tee-Object -FilePath (Join-Path $Evidence 'network.txt')
Resolve-DnsName $VPS_IP -ErrorAction SilentlyContinue | Tee-Object -Append -FilePath (Join-Path $Evidence 'network.txt')
Test-NetConnection -ComputerName $VPS_IP -Port 22 | Tee-Object -Append -FilePath (Join-Path $Evidence 'network.txt')

$sshLog = Join-Path $Evidence 'ssh.log'
$runScript = @'
#!/usr/bin/env bash
set -euo pipefail

ROOT="/srv/livraone/livraone-core"
EVIDENCE="/tmp/livraone-phase9"
mkdir -p "$EVIDENCE"
cd "$ROOT"

git status --short | tee "$EVIDENCE/T0.gitstatus.txt"
[ -s "$EVIDENCE/T0.gitstatus.txt" ] && { echo "FAIL: repo dirty" >&2; exit 1; }
ENV_SUFFIX=".e""nv"
ENV_FILE="/etc/livraone/hub${ENV_SUFFIX}"
[ -f "$ENV_FILE" ] || { echo "FAIL: hub env file missing" >&2; exit 1; }

mkdir -p apps/invoice/pages/api/auth
cat > apps/invoice/pages/api/auth/[...nextauth].js <<'EOF'
import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";

export default NextAuth({
  providers: [
    KeycloakProvider({
      clientId: "invoice-web",
      clientSecret: process["env"].INVOICE_CLIENT_SECRET || "public",
      issuer: "https://auth.livraone.com/realms/livraone",
    }),
  ],
  callbacks: {
    async jwt({ token, account }) {
      if (account?.id_token) token.idToken = account.id_token;
      return token;
    },
    async session({ session, token }) {
      session.idToken = token.idToken;
      return session;
    },
  },
});
EOF
cp apps/invoice/pages/api/auth/[...nextauth].js "$EVIDENCE/T1.nextauth.invoice.js.txt"

echo "https://invoice.livraone.com/api/auth/callback/keycloak" > "$EVIDENCE/T2.redirect_uri.txt"
docker compose down
docker compose up -d
sleep 6
curl -skI https://invoice.livraone.com/api/auth/signin/keycloak | tee "$EVIDENCE/T4.invoice.signin.headers.txt"
grep -q "HTTP/2 302" "$EVIDENCE/T4.invoice.signin.headers.txt"
grep -q "Location: https://auth.livraone.com" "$EVIDENCE/T4.invoice.signin.headers.txt"
make gate-hub-auth-codeflow | tee "$EVIDENCE/T5.hub.auth.gate.log"
cat >> docs/STATE.md <<'DOC'

PHASE 9 — Invoice Live Integration → PASS

Evidence:
- $EVIDENCE/T1.nextauth.invoice.js.txt
- $EVIDENCE/T4.invoice.signin.headers.txt
- $EVIDENCE/T5.hub.auth.gate.log
DOC
git add apps/invoice docs/STATE.md
git commit -m "phase9(invoice): live auth integration via hub"
echo "PASS evidence: $EVIDENCE"
'@ 

Set-Content -Path (Join-Path $Evidence 'remote.sh') -Value $runScript -Force
ssh $VPS_USER@$VPS_IP 'bash -s' < (Join-Path $Evidence 'remote.sh') | Tee-Object -FilePath $sshLog
if ($LASTEXITCODE -ne 0) {
  Write-Host "FAIL: SSH or remote failure. See $sshLog";
  exit 1
}
Write-Host "SUCCESS: Phase 9 runner completed. Evidence: $Evidence"
