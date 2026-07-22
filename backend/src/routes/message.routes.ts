import { Router } from 'express';
import {
  sendMessage,
  getBookingMessages,
  getDirectConversation,
  getMyUnreadCount,
  getMyConversations,
} from '../controllers/message.controller';
import { authenticate } from '../middleware/auth';
<<<<<<< HEAD
import { messageSendLimiter } from '../middleware/rateLimit';
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

const router = Router();

router.use(authenticate);

<<<<<<< HEAD
router.post('/', messageSendLimiter, sendMessage);
=======
router.post('/', sendMessage);
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
router.get('/conversations', getMyConversations);
router.get('/unread-count', getMyUnreadCount);
router.get('/direct/:userId', getDirectConversation);
router.get('/booking/:bookingId', getBookingMessages);

export default router;
