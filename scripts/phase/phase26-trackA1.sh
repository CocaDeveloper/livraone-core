# =========================================================
# LIVRAONE — PHASE 26 (TRACK A1: CONVERSION UX)
# MODE: EXECUTION-FIRST (DISCOVERY + MINIMAL PATCHES)
# GOALS:
#   - Add /login link in marketing navbar/header
#   - Route "Start Free Trial" CTA to /login (marketing)
#   - Add "How did you hear about us?" field in hub register/signup UI
#   - Gates PASS, PR opened
#
# RULES: SSOT only (/etc/livraone/hub.env). NO .env. DO NOT PRINT SECRETS.
# =========================================================
set -euo pipefail
set +x

PHASE="phase26-trackA1"
TS="$(date +%Y%m%d-%H%M%S)"
EVID="/tmp/livraone-${PHASE}.${TS}"
OUTDIR="/srv/livraone/evidence"
REPO="${REPO:-/srv/livraone/livraone-core}"
BRANCH="phase26/marketing-login-register-attribution-${TS}"
OWNER_REPO="${OWNER_REPO:-CocaDeveloper/livraone-core}"

mkdir -p "$EVID"
exec > >(tee -a "$EVID/commands.log") 2>&1

command -v git >/dev/null
command -v rg >/dev/null
command -v python3 >/dev/null

echo "==> EVID=$EVID"
echo "==> BRANCH=$BRANCH"

STAT_LINE="$(stat -c '%a %U %G %n' /etc/livraone/hub.env || true)"
echo "$STAT_LINE" | tee "$EVID/ssot_stat.txt"
echo "$STAT_LINE" | grep -q '^600 root root ' || { echo "FAIL: SSOT perms invalid"; exit 1; }

cd "$REPO"
git fetch origin --prune
git checkout main
git pull --ff-only origin main

if [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: working tree not clean"
  git status --porcelain | tee "$EVID/git_status_porcelain.txt"
  exit 1
fi

git checkout -b "$BRANCH"

echo "==> Discovery: marketing/navbar/header candidates"
rg -n "(Navbar|Header|Start Free Trial|Free Trial|Login|Sign In)" apps -S \
  | head -n 250 | tee "$EVID/rg_marketing_hits.txt" >/dev/null || true

python3 - <<'PY'
import pathlib, re, json
roots = [pathlib.Path("apps/marketing"), pathlib.Path("apps/web")]
cands = []
for r in roots:
    if not r.exists():
        continue
    for p in r.rglob("*.tsx"):
        txt = p.read_text(encoding="utf-8", errors="ignore")
        score = 0
        if re.search(r'\bNavbar\b|\bHeader\b', txt): score += 3
        if re.search(r'Start Free Trial|Free Trial', txt, re.I): score += 5
        if re.search(r'href=["\']\/login["\']', txt): score -= 2
        if re.search(r'components/(navbar|header)', str(p), re.I): score += 4
        if score > 0:
            cands.append((score, str(p)))
cands.sort(reverse=True)
print(json.dumps(cands[:15], indent=2))
PY >"$EVID/marketing_candidates.json" 2>&1

echo "==> Top marketing candidates:"
cat "$EVID/marketing_candidates.json"

MARKETING_FILE="$(EVID="$EVID" python3 - <<'PY'
import json
import os
EVID = os.environ["EVID"]
with open(f"{EVID}/marketing_candidates.json") as fp:
    c = json.load(fp)
print(c[0][1] if c else "")
PY
 )"

if [ -z "$MARKETING_FILE" ] || [ ! -f "$MARKETING_FILE" ]; then
  echo "FAIL: Could not auto-select marketing file. See $EVID/marketing_candidates.json"
  exit 1
fi

echo "marketing_target=$MARKETING_FILE" | tee "$EVID/marketing_target.txt"
cp -a "$MARKETING_FILE" "$EVID/marketing.before.tsx"

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("'"$MARKETING_FILE"'")
s = p.read_text(encoding="utf-8", errors="ignore")
orig = s
s = re.sub(r'(href=["\'])\/(register|signup|free-trial|trial|start)(["\'])', r'\1/login\3', s, flags=re.I)
if not re.search(r'href=["\']\/login["\']', s):
    m = re.search(r'(Start Free Trial|Free Trial)', s, flags=re.I)
    if m:
        lines = s.splitlines()
        idx = None
        for i, line in enumerate(lines):
            if re.search(r'Start Free Trial|Free Trial', line, re.I):
                idx = i
                break
        login = '  {/* Phase26 */} <a href="/login" className="ml-3 text-sm font-medium">Login</a>'
        if idx is not None:
            lines.insert(idx+1, login)
            s = "\n".join(lines)
        else:
            s += "\n" + login + "\n"
    else:
        s += '\n{/* Phase26 */}<a href="/login" className="text-sm font-medium">Login</a>\n'
if s != orig:
    p.write_text(s, encoding="utf-8")
PY >"$EVID/patch_marketing.log" 2>&1

cp -a "$MARKETING_FILE" "$EVID/marketing.after.tsx"

echo "==> Discovery: hub auth UI candidates"
rg -n "(register|signup|create account|Start free trial|Don't have an account)" apps/hub/app -S \
  | head -n 250 | tee "$EVID/rg_hub_auth_hits.txt" >/dev/null || true

python3 - <<'PY'
import pathlib, re, json
root = pathlib.Path("apps/hub/app")
cands=[]
for p in root.rglob("page.tsx"):
    txt = p.read_text(encoding="utf-8", errors="ignore")
    score=0
    if re.search(r'register|signup|create account', txt, re.I): score+=6
    if re.search(r'Don\'t have an account|Start free trial', txt, re.I): score+=4
    if score>0:
        cands.append((score,str(p)))
cands.sort(reverse=True)
print(json.dumps(cands[:15], indent=2))
PY >"$EVID/hub_auth_candidates.json" 2>&1

echo "==> Top hub auth candidates:"
cat "$EVID/hub_auth_candidates.json"

HUB_AUTH_FILE="$(python3 - <<'PY'
import json
c=json.load(open("'"$EVID"'/hub_auth_candidates.json"))
print(c[0][1] if c else "")
PY
)"

if [ -z "$HUB_AUTH_FILE" ] || [ ! -f "$HUB_AUTH_FILE" ]; then
  echo "FAIL: Could not auto-select hub auth page. See $EVID/hub_auth_candidates.json"
  exit 1
fi

echo "hub_auth_target=$HUB_AUTH_FILE" | tee "$EVID/hub_auth_target.txt"
cp -a "$HUB_AUTH_FILE" "$EVID/hub_auth.before.tsx"

python3 - <<'PY'
import pathlib
p = pathlib.Path("'"$HUB_AUTH_FILE"'")
s = p.read_text(encoding="utf-8", errors="ignore")
marker = "/* Phase26 attribution */"
if marker not in s:
    select_jsx = f"""
{marker}
<div className="mt-4">
  <label className="block text-sm font-medium">How did you hear about us?</label>
  <select name="ref_source" className="mt-1 w-full rounded-md border px-3 py-2">
    <option value="">Select one</option>
    <option value="google">Google</option>
    <option value="facebook">Facebook</option>
    <option value="instagram">Instagram</option>
    <option value="referral">Referral</option>
    <option value="other">Other</option>
  </select>
</div>
"""
    if "</form>" in s:
        s = s.replace("</form>", select_jsx + "\n</form>", 1)
    else:
        s += "\n" + select_jsx + "\n"
    p.write_text(s, encoding="utf-8")
PY >"$EVID/patch_attribution.log" 2>&1

cp -a "$HUB_AUTH_FILE" "$EVID/hub_auth.after.tsx"

echo "==> Run deterministic gates (SSOT loaded)..."
mkdir -p "$EVID/gates"
(
  export CI=1
  export CI_GATES_RUNNER=1
  export RUN_GATES_SECRETS_LOADED=1
  . ./scripts/lib/ssot_env.sh
  ssot_load "/etc/livraone/hub.env"
  ./scripts/run-gates.sh
) >"$EVID/gates/run.log" 2>&1 || {
  echo "FAIL: gates failed"
  tail -n 160 "$EVID/gates/run.log" || true
  exit 1
}

echo "PASS: gates" | tee "$EVID/gates/result.txt"

if [ -z "$(git status --porcelain)" ]; then
  echo "FAIL: no changes detected; expected Phase26 modifications"
  exit 1
fi

git add -A
git commit -m "phase26(trackA1): login CTA + trial->login routing + attribution field" \
  | tee "$EVID/git_commit.txt" >/dev/null

git push -u origin "$BRANCH" >"$EVID/git_push.log" 2>&1

if command -v gh >/dev/null; then
  gh pr create -R "$OWNER_REPO" -B main -H "$BRANCH" \
    -t "Phase26 Track A1: Conversion UX (Login + Trial routing + Attribution)" \
    -b "Adds Login in marketing navbar/header, routes Start Free Trial to /login, adds attribution select to hub auth UI. Evidence: $EVID" \
    >"$EVID/pr_create.txt" 2>&1 || true
  cat "$EVID/pr_create.txt" || true
fi

mkdir -p "$OUTDIR"
BUNDLE="${OUTDIR}/${PHASE}.${TS}"
mkdir -p "$BUNDLE"
rsync -a "$EVID/" "$BUNDLE/"
( cd "$OUTDIR" && sha256sum -b "$(basename "$BUNDLE")"/**/* 2>/dev/null | sort -k2 ) \
  | tee "${BUNDLE}.sha256.txt" >/dev/null || true

echo "PASS: Phase26 Track A1 complete"
echo "Evidence: $BUNDLE"
