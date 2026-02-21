import { NextResponse } from "next/server";
import { prisma } from "../../../../lib/prisma";

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

export async function GET(_req: Request, ctx: { params: Promise<{ id: string }> }) {
  const { id } = await ctx.params;
  const row = await prisma.project.findFirst({
    where: { id, orgId: DEFAULT_ORG_ID },
  });
  if (!row) {
    return NextResponse.json({ error: "not_found" }, { status: 404 });
  }
  return NextResponse.json({ item: toProjectResponse(row) });
}
