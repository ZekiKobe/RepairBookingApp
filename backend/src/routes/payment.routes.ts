import { Router } from 'express';
import {
  createPaymentIntent,
  confirmPayment,
  getPaymentStatus,
  paymentWebhook,
  refundPayment,
} from '../controllers/payment.controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

// Webhook — no auth (called by Chapa/Telebirr servers)
router.post('/webhook', paymentWebhook);

router.use(authenticate);

router.post('/intent', createPaymentIntent);
router.post('/confirm', confirmPayment);
router.post('/refund', authorize('admin'), refundPayment);
router.get('/status/:bookingId', getPaymentStatus);

export default router;
