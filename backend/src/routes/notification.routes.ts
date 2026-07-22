import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { getMyNotifications, getMyUnreadCount, markAllAsRead, markOneAsRead } from '../controllers/notification.controller';

const router = Router();

router.use(authenticate);

router.get('/', getMyNotifications);
router.get('/unread-count', getMyUnreadCount);
router.put('/read-all', markAllAsRead);
router.put('/:id/read', markOneAsRead);

export default router;
