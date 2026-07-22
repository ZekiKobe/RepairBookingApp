/** Must match backend `PERMISSIONS` strings */
export const P = {
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

export type PermissionKey = (typeof P)[keyof typeof P];
