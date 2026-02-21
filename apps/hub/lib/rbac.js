export function extractRoles(sessionOrToken) {
  if (!sessionOrToken) {
    return [];
  }
  if (sessionOrToken.realm_access?.roles) {
    return sessionOrToken.realm_access.roles;
  }
  if (sessionOrToken.user?.realm_access?.roles) {
    return sessionOrToken.user.realm_access.roles;
  }
  return [];
}

export function hasRole(sessionOrToken, role) {
  return extractRoles(sessionOrToken).includes(role);
}
