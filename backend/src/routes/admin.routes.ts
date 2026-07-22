import { Router } from 'express';
import {
  getDashboardStats,
  getAllUsersAdmin,
  toggleUserStatus,
  getAuditLogs,
} from '../controllers/admin.controller';
import {
  getDashboardAnalytics,
  listFinanceLedger,
  getPlatformSettings,
  putPlatformSettings,
  listNotificationTemplates,
  createNotificationTemplate,
  updateNotificationTemplate,
  deleteNotificationTemplate,
  broadcastNotification,
  getTechnicianSuggestions,
} from '../controllers/adminManagement.controller';
import { authenticate, authorize } from '../middleware/auth';
import { authorizePermission } from '../middleware/authorizePermission';
import { PERMISSIONS } from '../config/adminPermissions';

const router = Router();

router.use(authenticate, authorize('admin'));

router.get('/dashboard', authorizePermission(PERMISSIONS.DASHBOARD_READ), getDashboardStats);
router.get('/dashboard/analytics', authorizePermission(PERMISSIONS.DASHBOARD_READ), getDashboardAnalytics);

router.get('/audit-log', authorizePermission(PERMISSIONS.AUDIT_READ), getAuditLogs);

router.get('/users', authorizePermission(PERMISSIONS.USERS_READ), getAllUsersAdmin);
router.put('/users/:id/toggle', authorizePermission(PERMISSIONS.USERS_WRITE), toggleUserStatus);

router.get('/finance/ledger', authorizePermission(PERMISSIONS.FINANCE_READ), listFinanceLedger);

router.get('/settings', authorizePermission(PERMISSIONS.SETTINGS_READ), getPlatformSettings);
router.put('/settings', authorizePermission(PERMISSIONS.SETTINGS_WRITE), putPlatformSettings);

router.get('/notification-templates', authorizePermission(PERMISSIONS.NOTIFICATIONS_READ), listNotificationTemplates);
router.post('/notification-templates', authorizePermission(PERMISSIONS.NOTIFICATIONS_WRITE), createNotificationTemplate);
router.put('/notification-templates/:id', authorizePermission(PERMISSIONS.NOTIFICATIONS_WRITE), updateNotificationTemplate);
router.delete('/notification-templates/:id', authorizePermission(PERMISSIONS.NOTIFICATIONS_WRITE), deleteNotificationTemplate);
router.post('/notifications/broadcast', authorizePermission(PERMISSIONS.NOTIFICATIONS_WRITE), broadcastNotification);

router.get('/technicians/suggestions', authorizePermission(PERMISSIONS.BOOKINGS_READ), getTechnicianSuggestions);

export default router;
