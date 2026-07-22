import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth';
import { computePermissionsForAdminRole, hasPermission, PermissionKey, AdminAppRole } from '../config/adminPermissions';

/**
 * Requires authenticate first. Uses `adminRole` on the loaded user (default super_admin if unset).
 */
export const authorizePermission =
  (...required: PermissionKey[]) =>
  (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ success: false, message: 'Authentication required' });
      return;
    }
    if (req.user.role !== 'admin') {
      res.status(403).json({ success: false, message: 'Administrator access required' });
      return;
    }

    const adminRole = ((req.user as { adminRole?: AdminAppRole }).adminRole ?? 'super_admin') as AdminAppRole;
    const permissions = computePermissionsForAdminRole(adminRole);

    for (const p of required) {
      if (!hasPermission(permissions, p)) {
        res.status(403).json({ success: false, message: 'Insufficient permissions' });
        return;
      }
    }
    (req as AuthRequest & { adminPermissions?: PermissionKey[] }).adminPermissions = permissions;
    next();
  };
