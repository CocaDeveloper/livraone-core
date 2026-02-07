#!/usr/bin/env bash
set -euo pipefail

ROOT="/srv/livraone/livraone-core"
EVIDENCE="/tmp/livraone-phase9"

mkdir -p "$EVIDENCE"
cd "$ROOT"

git status --short > "$EVIDENCE/T0.gitstatus.txt"
[ -s "$EVIDENCE/T0.gitstatus.txt" ] && { echo "FAIL: repo dirty" >&2; cat "$EVIDENCE/T0.gitstatus.txt" >&2; exit 1; }

[ -f "$ROOT/.env" ] || { echo "FAIL: missing $ROOT/.env" >&2; exit 1; }

mkdir -p apps/invoice/pages/api/auth
cat > apps/invoice/pages/api/auth/[...nextauth].js <<'EOF'
const NextAuth = require("next-auth");
const KeycloakProvider = require("next-auth/providers/keycloak");

module.exports = NextAuth({
  providers: [
    KeycloakProvider({
      clientId: "invoice-web",
      clientSecret: process.env.INVOICE_CLIENT_SECRET || "public",
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

curl -skI https://invoice.livraone.com/api/auth/signin/keycloak \
  | tee "$EVIDENCE/T4.invoice.signin.headers.txt"
grep -q "HTTP/2 302" "$EVIDENCE/T4.invoice.signin.headers.txt"
grep -q "Location: https://auth.livraone.com" "$EVIDENCE/T4.invoice.signin.headers.txt"

make gate-hub-auth-codeflow | tee "$EVIDENCE/T5.hub.auth.gate.log"

cat >> docs/STATE.md <<EOF

PHASE 9 — Invoice Live Integration → PASS

Evidence:
- $EVIDENCE/T1.nextauth.invoice.js.txt
- $EVIDENCE/T4.invoice.signin.headers.txt
- $EVIDENCE/T5.hub.auth.gate.log
EOF

git add apps/invoice docs/STATE.md
git commit -m "phase9(invoice): live auth integration via hub"

echo "[phase9] PASS – evidence at $EVIDENCE"
