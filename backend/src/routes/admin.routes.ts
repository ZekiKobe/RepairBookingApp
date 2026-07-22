import { Router } from 'express';
import {
  getDashboardStats,
  getAllUsersAdmin,
  toggleUserStatus,
<<<<<<< HEAD
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
=======
} from '../controllers/admin.controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

// All admin routes require authentication and admin role
router.use(authenticate, authorize('admin'));

router.get('/dashboard', getDashboardStats);
router.get('/users', getAllUsersAdmin);
router.put('/users/:id/toggle', toggleUserStatus);
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

export default router;
