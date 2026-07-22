import { Router } from 'express';
import {
  register,
  login,
  refreshToken,
  getMe,
  forgotPassword,
  verifyOtp,
  resetPassword,
  changePassword,
  googleAuth,
} from '../controllers/auth.controller';
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
router.put('/change-password', authenticate, changePassword);
router.post('/forgot-password', otpFlowLimiter, forgotPassword);
router.post('/verify-otp', otpFlowLimiter, verifyOtp);
router.post('/reset-password', otpFlowLimiter, resetPassword);
router.post('/google', loginRegisterLimiter, googleAuth);

export default router;
