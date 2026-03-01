import { NextResponse } from 'next/server';
import { assertFeatureForTenant } from '@/lib/features';
import { parseTenantFromHost, requireTenantId } from '@/lib/tenant';

export async function POST(req: Request) {
  const body = await req.json().catch(() => ({} as any));
  const feature = (body?.feature ?? '') as any;

  const host = req.headers.get('host');
  const tenantParsed = parseTenantFromHost(host);
  const tenantId = requireTenantId(tenantParsed);

  try {
    await assertFeatureForTenant(tenantId, feature);
    return NextResponse.json({ ok: true });
  } catch (err: any) {
    return NextResponse.json(
      { ok: false, error: err?.message ?? 'FEATURE_DISABLED' },
      { status: 403 }
    );
  }
}
