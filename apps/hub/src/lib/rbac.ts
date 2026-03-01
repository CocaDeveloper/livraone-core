/**
 * Phase 34 — RBAC contract module
 * - No auth model changes.
 * - Deterministic permission checks based on role strings.
 *
 * Integration edge: adapt your session/claims -> roles: string[]
 */

export type Role = string;
export type Permission = string;

export class RbacError extends Error {
  code: 'RBAC_UNAUTHENTICATED' | 'RBAC_FORBIDDEN';
  constructor(code: 'RBAC_UNAUTHENTICATED' | 'RBAC_FORBIDDEN', message?: string) {
    super(message ?? code);
    this.code = code;
  }
}

export type RbacPrincipal = {
  roles?: Role[] | null;
};

type Matrix = {
  roles: Role[];
  permissions: Permission[];
  grants: Record<string, Permission[]>;
};

const DEFAULT_MATRIX: Matrix = {
  roles: ['owner', 'admin', 'member', 'viewer', 'billing', 'support'],
  permissions: [
    'tenant:read','tenant:write',
    'users:read','users:invite','users:remove',
    'billing:read','billing:write',
    'settings:read','settings:write',
    'audit:read',
    'content:read','content:write',
  ],
  grants: {
    owner:   ['*'],
    admin:   ['tenant:read','tenant:write','users:read','users:invite','users:remove','billing:read','billing:write','settings:read','settings:write','audit:read','content:read','content:write'],
    member:  ['tenant:read','users:read','billing:read','settings:read','content:read','content:write'],
    viewer:  ['tenant:read','users:read','billing:read','settings:read','content:read'],
    billing: ['tenant:read','billing:read','billing:write','settings:read'],
    support: ['tenant:read','users:read','audit:read','content:read'],
  },
};

export function hasPermission(roles: Role[] | null | undefined, permission: Permission, matrix: Matrix = DEFAULT_MATRIX): boolean {
  if (!roles || roles.length === 0) return false;

  for (const r of roles) {
    const grants = matrix.grants[r] ?? [];
    if (grants.includes('*')) return true;
    if (grants.includes(permission)) return true;
  }
  return false;
}

export function assertPermission(principal: RbacPrincipal | null | undefined, permission: Permission, matrix: Matrix = DEFAULT_MATRIX): void {
  const roles = principal?.roles ?? null;
  if (!roles || roles.length === 0) throw new RbacError('RBAC_UNAUTHENTICATED');
  if (!hasPermission(roles, permission, matrix)) throw new RbacError('RBAC_FORBIDDEN');
}
