import { Router } from 'express';
import {
  createPaymentIntent,
  confirmPayment,
  getPaymentStatus,
  paymentWebhook,
<<<<<<< HEAD
  refundPayment,
} from '../controllers/payment.controller';
import { authenticate, authorize } from '../middleware/auth';
=======
} from '../controllers/payment.controller';
import { authenticate } from '../middleware/auth';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

const router = Router();

// Webhook — no auth (called by Chapa/Telebirr servers)
router.post('/webhook', paymentWebhook);

router.use(authenticate);

router.post('/intent', createPaymentIntent);
router.post('/confirm', confirmPayment);
<<<<<<< HEAD
router.post('/refund', authorize('admin'), refundPayment);
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
router.get('/status/:bookingId', getPaymentStatus);

export default router;
