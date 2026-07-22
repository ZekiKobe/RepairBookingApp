import { Router } from 'express';
<<<<<<< HEAD
import { register, login, refreshToken, getMe, forgotPassword, verifyOtp, resetPassword, googleAuth } from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth';
import {
  authRouterLimiter,
  loginRegisterLimiter,
  otpFlowLimiter,
} from '../middleware/rateLimit';

const router = Router();

router.use(authRouterLimiter);

router.post('/register', loginRegisterLimiter, register);
router.post('/login', loginRegisterLimiter, login);
router.post('/refresh', loginRegisterLimiter, refreshToken);
router.get('/me', authenticate, getMe);
router.post('/forgot-password', otpFlowLimiter, forgotPassword);
router.post('/verify-otp', otpFlowLimiter, verifyOtp);
router.post('/reset-password', otpFlowLimiter, resetPassword);
router.post('/google', loginRegisterLimiter, googleAuth);
=======
import { register, login, refreshToken, getMe, forgotPassword, verifyOtp, resetPassword } from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.post('/refresh', refreshToken);
router.get('/me', authenticate, getMe);
router.post('/forgot-password', forgotPassword);
router.post('/verify-otp', verifyOtp);
router.post('/reset-password', resetPassword);
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

export default router;
