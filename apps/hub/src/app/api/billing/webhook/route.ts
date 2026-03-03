import { NextResponse } from 'next/server';
import { handleWebhook } from '@/lib/billing/provider';

export async function POST(req: Request) {
  const body = await req.json().catch(() => null);

  try {
    await handleWebhook(body);
    return NextResponse.json({ ok: true });
  } catch (err: any) {
    return NextResponse.json(
      { error: err.message || 'WEBHOOK_ERROR' },
      { status: 400 }
    );
  }
}
