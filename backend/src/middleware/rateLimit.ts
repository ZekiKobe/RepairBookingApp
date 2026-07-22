import rateLimit from 'express-rate-limit';

const window15m = 15 * 60 * 1000;
const window1h = 60 * 60 * 1000;

/** Broad limit for all /api/auth requests */
export const authRouterLimiter = rateLimit({
  windowMs: window15m,
  max: 120,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests. Try again later.' },
});

export const loginRegisterLimiter = rateLimit({
  windowMs: window15m,
  max: 40,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many login attempts. Try again later.' },
});

export const otpFlowLimiter = rateLimit({
  windowMs: window1h,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many password reset attempts. Try again in an hour.' },
});

export const messageSendLimiter = rateLimit({
  windowMs: window1h,
  max: 500,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many messages sent. Try again later.' },
});

export const uploadLimiter = rateLimit({
  windowMs: window15m,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many uploads. Try again later.' },
});
