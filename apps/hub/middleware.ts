import { enforceSubscription } from './src/lib/subscription/middleware_enforce';
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { getToken } from "next-auth/jwt";

const PUBLIC_PATHS = [
  "/api/health",
  "/api/auth",
  "/login",
  "/post-auth",
  "/logout",
  "/favicon.ico",
  "/_next"
];

export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;
  const isPublic = PUBLIC_PATHS.some((path) => pathname === path || pathname.startsWith(path + "/") || pathname.startsWith(path));
  if (isPublic) {
    return NextResponse.next();
  }

  const token = await getToken({ req, secret: process.env.NEXTAUTH_SECRET });
  if (!token) {
    const loginUrl = req.nextUrl.clone();
    loginUrl.pathname = "/login";
    loginUrl.searchParams.set("from", pathname);
    return NextResponse.redirect(loginUrl);
  }

  const enforced = enforceSubscription(req);
  if (enforced) return enforced;

  return NextResponse.next();
}

export const config = {
  matcher: ["/:path*"]
};
