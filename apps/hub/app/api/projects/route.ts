import { NextResponse } from "next/server";
import { prisma } from "../../../lib/prisma";

const DEFAULT_ORG_ID = "00000000-0000-0000-0000-000000000000";

function toProjectResponse(p: any) {
  return {
    id: p.id,
    name: p.name,
    description: p.address ?? undefined,
    status: p.status,
    createdAt: new Date(p.createdAt).toISOString(),
    updatedAt: new Date(p.updatedAt).toISOString(),
  };
}

export async function GET() {
  const rows = await prisma.project.findMany({
    where: { orgId: DEFAULT_ORG_ID },
    orderBy: { createdAt: "desc" },
  });
  return NextResponse.json({ items: rows.map(toProjectResponse) });
}

export async function POST(req: Request) {
  let body: any = null;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const name = String(body?.name ?? "").trim();
  const description = String(body?.description ?? "").trim();
  if (!name) {
    return NextResponse.json({ error: "name_required" }, { status: 400 });
  }

  const row = await prisma.project.create({
    data: {
      orgId: DEFAULT_ORG_ID,
      name,
      address: description || null,
      status: "active",
    },
  });

  return NextResponse.json({ item: toProjectResponse(row) }, { status: 201 });
}
