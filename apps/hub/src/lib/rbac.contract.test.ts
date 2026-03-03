import { hasPermission, assertPermission } from './rbac';

const ok = hasPermission(['owner'], 'tenant:write');
if (!ok) throw new Error('RBAC_CONTRACT_BROKEN');

assertPermission({ roles: ['admin'] }, 'tenant:read');
