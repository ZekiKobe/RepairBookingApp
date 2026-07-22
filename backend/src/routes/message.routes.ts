import { Router } from 'express';
import {
  sendMessage,
  getBookingMessages,
  getDirectConversation,
  getMyUnreadCount,
  getMyConversations,
} from '../controllers/message.controller';
import { authenticate } from '../middleware/auth';
import { messageSendLimiter } from '../middleware/rateLimit';

const router = Router();

router.use(authenticate);

router.post('/', messageSendLimiter, sendMessage);
router.get('/conversations', getMyConversations);
router.get('/unread-count', getMyUnreadCount);
router.get('/direct/:userId', getDirectConversation);
router.get('/booking/:bookingId', getBookingMessages);

export default router;
