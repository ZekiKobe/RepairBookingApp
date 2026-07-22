export type AdminAppRole =
  | 'super_admin'
  | 'operations'
  | 'support'
  | 'finance'
  | 'technician_manager'
  | 'read_only';

/** Fine-grained permission strings; extend over time. */
export const PERMISSIONS = {
  DASHBOARD_READ: 'dashboard.read',
  BOOKINGS_READ: 'bookings.read',
  BOOKINGS_WRITE: 'bookings.write',
  USERS_READ: 'users.read',
  USERS_WRITE: 'users.write',
  TECHNICIANS_READ: 'technicians.read',
  TECHNICIANS_WRITE: 'technicians.write',
  FINANCE_READ: 'finance.read',
  FINANCE_WRITE: 'finance.write',
  NOTIFICATIONS_READ: 'notifications.read',
  NOTIFICATIONS_WRITE: 'notifications.write',
  REPORTS_READ: 'reports.read',
  SETTINGS_READ: 'settings.read',
  SETTINGS_WRITE: 'settings.write',
  AUDIT_READ: 'audit.read',
} as const;

export type PermissionKey = (typeof PERMISSIONS)[keyof typeof PERMISSIONS];

const ALL = Object.values(PERMISSIONS) as PermissionKey[];

const READ = [
  PERMISSIONS.DASHBOARD_READ,
  PERMISSIONS.BOOKINGS_READ,
  PERMISSIONS.USERS_READ,
  PERMISSIONS.TECHNICIANS_READ,
  PERMISSIONS.FINANCE_READ,
  PERMISSIONS.NOTIFICATIONS_READ,
  PERMISSIONS.REPORTS_READ,
  PERMISSIONS.SETTINGS_READ,
  PERMISSIONS.AUDIT_READ,
] as PermissionKey[];

const ROLE_MATRIX: Record<AdminAppRole, PermissionKey[]> = {
  super_admin: ALL,
  operations: [
    PERMISSIONS.DASHBOARD_READ,
    PERMISSIONS.BOOKINGS_READ,
    PERMISSIONS.BOOKINGS_WRITE,
    PERMISSIONS.USERS_READ,
    PERMISSIONS.USERS_WRITE,
    PERMISSIONS.TECHNICIANS_READ,
    PERMISSIONS.TECHNICIANS_WRITE,
    PERMISSIONS.NOTIFICATIONS_READ,
    PERMISSIONS.NOTIFICATIONS_WRITE,
    PERMISSIONS.REPORTS_READ,
    PERMISSIONS.AUDIT_READ,
  ],
  support: [
    PERMISSIONS.DASHBOARD_READ,
    PERMISSIONS.BOOKINGS_READ,
    PERMISSIONS.BOOKINGS_WRITE,
    PERMISSIONS.USERS_READ,
    PERMISSIONS.TECHNICIANS_READ,
    PERMISSIONS.NOTIFICATIONS_READ,
    PERMISSIONS.NOTIFICATIONS_WRITE,
    PERMISSIONS.REPORTS_READ,
  ],
  finance: [
    PERMISSIONS.DASHBOARD_READ,
    PERMISSIONS.BOOKINGS_READ,
    PERMISSIONS.FINANCE_READ,
    PERMISSIONS.FINANCE_WRITE,
    PERMISSIONS.REPORTS_READ,
    PERMISSIONS.AUDIT_READ,
  ],
  technician_manager: [
    PERMISSIONS.DASHBOARD_READ,
    PERMISSIONS.BOOKINGS_READ,
    PERMISSIONS.BOOKINGS_WRITE,
    PERMISSIONS.TECHNICIANS_READ,
    PERMISSIONS.TECHNICIANS_WRITE,
    PERMISSIONS.REPORTS_READ,
    PERMISSIONS.AUDIT_READ,
  ],
  read_only: READ,
};

export function computePermissionsForAdminRole(role: AdminAppRole | undefined | null): PermissionKey[] {
  if (!role) return ALL;
  return [...(ROLE_MATRIX[role] ?? READ)];
}

export function hasPermission(granted: PermissionKey[] | undefined, required: PermissionKey): boolean {
  if (!granted?.length) return false;
  return granted.includes(required);
}
