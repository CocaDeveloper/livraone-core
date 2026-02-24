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
  "/_next",
  "/onboarding"
];

const ONBOARDING_PATH = "/onboarding";

export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;
  const isPublic = PUBLIC_PATHS.some(
    (path) =>
      pathname === path ||
      pathname.startsWith(path + "/") ||
      pathname.startsWith(path)
  );
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

  const isOnboardingRoute =
    pathname === ONBOARDING_PATH || pathname.startsWith(ONBOARDING_PATH + "/");

  const onboardingComplete = token?.onboardingComplete ?? false;

  if (!onboardingComplete && !isOnboardingRoute) {
    const onboardingUrl = req.nextUrl.clone();
    onboardingUrl.pathname = ONBOARDING_PATH;
    return NextResponse.redirect(onboardingUrl);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/:path*"]
};
