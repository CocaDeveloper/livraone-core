import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json(
    { ok: true, service: "hub", ts: new Date().toISOString() },
    { status: 200 }
  );
}
