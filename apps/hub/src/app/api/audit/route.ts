// ---------------------------------------------------------
// Phase 49 — Tenant-scoped audit query API + RBAC enforcement
// Minimal integration, no redesign.
// ---------------------------------------------------------

import { NextResponse } from "next/server";
import { getToken } from "next-auth/jwt";
import { prisma } from "@/lib/prisma";
import { hasPermission } from "@/lib/rbac";
import { parseTenantFromHost, requireTenantId } from "@/lib/tenant";

function parseIntSafe(v: string | null, def: number, min: number, max: number): number {
  if (!v) return def;
  const n = Number(v);
  if (!Number.isFinite(n)) return def;
  return Math.max(min, Math.min(max, Math.floor(n)));
}

function parseDateSafe(v: string | null): Date | null {
  if (!v) return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

function rolesFromToken(token: any): string[] {
  if (!token) return [];
  if (Array.isArray(token.roles)) return token.roles.map(String);
  if (token.role) return [String(token.role)];
  return [];
}

export async function GET(req: Request) {
  const token = await getToken({ req, secret: process.env.NEXTAUTH_SECRET });
  if (!token) return new NextResponse("Unauthorized", { status: 401 });

  const roles = rolesFromToken(token);
  if (!hasPermission(roles, "audit:read")) {
    return new NextResponse("Forbidden", { status: 403 });
  }

  const host = req.headers.get("host");
  const tenantId = requireTenantId(parseTenantFromHost(host));

  const url = new URL(req.url);
  const limit = parseIntSafe(url.searchParams.get("limit"), 50, 1, 200);
  const cursor = url.searchParams.get("cursor");
  const action = url.searchParams.get("action");
  const actorId = url.searchParams.get("actorId");
  const from = parseDateSafe(url.searchParams.get("from"));
  const to = parseDateSafe(url.searchParams.get("to"));

  const where: any = { tenantId };
  if (action) where.type = action;
  if (actorId) where.actorId = actorId;
  if (from || to) {
    where.createdAt = {};
    if (from) where.createdAt.gte = from;
    if (to) where.createdAt.lte = to;
  }

  const query: any = {
    where,
    orderBy: { createdAt: "desc" },
    take: limit,
  };
  if (cursor) {
    query.cursor = { id: cursor };
    query.skip = 1;
  }

  const rows = await prisma.auditLog.findMany(query);
  const nextCursor = rows.length ? rows[rows.length - 1].id : null;
  return NextResponse.json({ tenantId, items: rows, nextCursor });
}
