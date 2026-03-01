import { NextResponse } from "next/server";
import { requireAdminOrMasterEmail } from "@/lib/auth/admin_guard";
import { prisma } from "../../../../../lib/prisma";

function csvEscape(v: unknown): string {
  if (v === null || v === undefined) return "";
  const s = String(v);
  if (/[",\n\r]/.test(s)) return '"' + s.replace(/"/g, '""') + '"';
  return s;
}

export async function GET(): Promise<Response> {
  const denied = await requireAdminOrMasterEmail();
  if (denied) return denied;

  const rows = await prisma.user.findMany({
    select: {
      id: true,
      email: true,
      createdAt: true,
      marketingAttribution: true,
    },
    orderBy: { createdAt: "desc" },
  });

  const header = ["userId","email","createdAt","marketingAttribution"].join(",");
  const body = [
    header,
    ...rows.map(r => [
      csvEscape(r.id),
      csvEscape(r.email),
      csvEscape(r.createdAt?.toISOString?.() ?? r.createdAt),
      csvEscape(r.marketingAttribution),
    ].join(",")),
  ].join("\n");

  return new NextResponse(body, {
    status: 200,
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": 'attachment; filename="livraone_attribution_export.csv"',
      "Cache-Control": "no-store",
      "Pragma": "no-cache",
      "Expires": "0",
    },
  });
}
