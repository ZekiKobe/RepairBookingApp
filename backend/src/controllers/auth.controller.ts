import { Request, Response, NextFunction } from 'express';
import { registerUser, loginUser, refreshAccessToken, generateTokens } from '../services/auth.service';
import { computePermissionsForAdminRole } from '../config/adminPermissions';
import type { AdminAppRole } from '../config/adminPermissions';
import User from '../models/User';
import * as bcrypt from 'bcryptjs';
import { getSmsProvider } from '../services/sms';
import {
  savePasswordResetOtp,
  isPasswordResetOtpValid,
  consumePasswordResetOtp,
} from '../services/otp.service';

export const register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { phone, password, firstName, lastName, email, role } = req.body;
    
    const { user, tokens } = await registerUser({
      phone,
      password,
      firstName,
      lastName,
      email,
      role,
    });
    
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: {
          id: user._id,
          phone: user.phone,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          isVerified: user.isVerified,
        },
        tokens,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { phone, password } = req.body;
    
    const { user, tokens } = await loginUser(phone, password);
    
    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user._id,
          phone: user.phone,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          avatar: user.avatar,
          location: user.location,
          ...(user.role === 'admin'
            ? {
                adminRole: (user as { adminRole?: AdminAppRole }).adminRole ?? 'super_admin',
                permissions: computePermissionsForAdminRole(
                  ((user as { adminRole?: AdminAppRole }).adminRole ?? 'super_admin') as AdminAppRole
                ),
              }
            : {}),
        },
        tokens,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const refreshToken = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      res.status(400).json({ success: false, message: 'Refresh token is required' });
      return;
    }
    
    const tokens = await refreshAccessToken(refreshToken);
    
    res.json({
      success: true,
      message: 'Token refreshed successfully',
      data: { tokens },
    });
  } catch (error) {
    next(error);
  }
};

export const getMe = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = (req as any).user;
    const adminRole =
      user.role === 'admin' ? ((user as { adminRole?: AdminAppRole }).adminRole ?? 'super_admin') : undefined;
    const permissions = user.role === 'admin' ? computePermissionsForAdminRole(adminRole) : [];

    res.json({
      success: true,
      data: {
        user: {
          id: user._id,
          phone: user.phone,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          avatar: user.avatar,
          location: user.location,
          isVerified: user.isVerified,
          ...(user.role === 'admin' ? { adminRole, permissions } : {}),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

// Step 1: send OTP
export const forgotPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { phone } = req.body;
    if (!phone) {
      res.status(400).json({ success: false, message: 'Phone number is required' });
      return;
    }

    const user = await User.findOne({ phone });
    if (!user) {
      res.status(404).json({ success: false, message: 'No account found with this phone number' });
      return;
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    await savePasswordResetOtp(phone, otp, 10 * 60 * 1000);

    // Send OTP via configured SMS provider
    await getSmsProvider().sendOtp(phone, otp);

    const isDev = process.env.NODE_ENV !== 'production';
    res.json({
      success: true,
      message: 'OTP sent successfully',
      ...(isDev ? { data: { otp } } : {}), // only expose OTP in dev/mock mode
    });
  } catch (error) {
    next(error);
  }
};

// Step 2: verify OTP
export const verifyOtp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { phone, otp } = req.body;
    if (!phone || !otp) {
      res.status(400).json({ success: false, message: 'Phone and OTP are required' });
      return;
    }

    const valid = await isPasswordResetOtpValid(phone, otp);
    if (!valid) {
      res.status(400).json({ success: false, message: 'Invalid or expired OTP' });
      return;
    }

    res.json({ success: true, message: 'OTP verified successfully' });
  } catch (error) {
    next(error);
  }
};

// Step 3: reset password
export const resetPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { phone, otp, newPassword } = req.body;
    if (!phone || !otp || !newPassword) {
      res.status(400).json({ success: false, message: 'Phone, OTP and new password are required' });
      return;
    }
    if (newPassword.length < 6) {
      res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
      return;
    }

    const consumed = await consumePasswordResetOtp(phone, otp);
    if (!consumed) {
      res.status(400).json({ success: false, message: 'Invalid or expired OTP' });
      return;
    }

    const user = await User.findOne({ phone }).select('+password');
    if (!user) {
      res.status(404).json({ success: false, message: 'User not found' });
      return;
    }

    user.password = newPassword; // pre-save hook will hash it
    await user.save();

    res.json({ success: true, message: 'Password reset successfully' });
  } catch (error) {
    next(error);
  }
};

// ── Google OAuth2 ID-token auth (google-auth-library; Firebase Admin optional fallback) ──
async function verifyGoogleCredential(
  idToken: string,
  webClientId: string
): Promise<{ sub: string; email?: string; name?: string; picture?: string }> {
  const { OAuth2Client } = await import('google-auth-library');
  const client = new OAuth2Client(webClientId);
  const ticket = await client.verifyIdToken({
    idToken,
    audience: webClientId,
  });
  const p = ticket.getPayload();
  if (!p?.sub) {
    throw new Error('Invalid Google token payload');
  }
  return {
    sub: p.sub,
    email: p.email,
    name: p.name,
    picture: p.picture,
  };
}

async function verifyGoogleCredentialFirebaseFallback(
  idToken: string
): Promise<{ sub: string; email?: string; name?: string; picture?: string }> {
  const { initFirebase, isFirebaseReady } = await import('../config/firebase');
  initFirebase();
  if (!isFirebaseReady()) {
    throw new Error('Firebase not configured');
  }
  const admin = await import('firebase-admin');
  const decoded = await admin.auth().verifyIdToken(idToken);
  return {
    sub: decoded.uid,
    email: decoded.email,
    name: decoded.name as string | undefined,
    picture: decoded.picture as string | undefined,
  };
}

export const googleAuth = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { idToken, role = 'user' } = req.body;
    if (!idToken) {
      res.status(400).json({ success: false, message: 'ID token is required' });
      return;
    }

    const clientId = process.env.GOOGLE_CLIENT_ID;
    if (!clientId) {
      res.status(503).json({ success: false, message: 'Google authentication is not configured on this server' });
      return;
    }

    let googleUser: { sub: string; email?: string; name?: string; picture?: string };
    try {
      googleUser = await verifyGoogleCredential(idToken, clientId);
    } catch {
      try {
        googleUser = await verifyGoogleCredentialFirebaseFallback(idToken);
      } catch {
        res.status(401).json({ success: false, message: 'Invalid or expired Google token' });
        return;
      }
    }

    const { sub: uid, email, name, picture } = googleUser;
    const firstName = name?.split(' ')[0] ?? 'User';
    const lastName  = name?.split(' ').slice(1).join(' ') || 'Google';

    // Upsert user by googleUid or email
    let user = await User.findOne({ googleUid: uid });
    if (!user && email) {
      user = await User.findOne({ email });
    }

    if (user) {
      // Update google uid & avatar if missing
      if (!user.googleUid) {
        (user as any).googleUid = uid;
        if (picture && !user.avatar) user.avatar = picture;
        await user.save();
      }
    } else {
      // Create new user — no password required for social accounts
      user = await User.create({
        googleUid: uid,
        email: email ?? undefined,
        firstName,
        lastName,
        avatar: picture ?? undefined,
        role: ['user', 'technician'].includes(role) ? role : 'user',
        password: Math.random().toString(36).slice(-12) + '!Aa1', // random, never used
        isVerified: true,
        phone: `google_${uid}`, // placeholder; unique per user
      });
    }

    const tokens = generateTokens(user);

    res.json({
      success: true,
      message: 'Google authentication successful',
      data: {
        user: {
          id: user._id,
          phone: user.phone,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          avatar: user.avatar,
          isVerified: user.isVerified,
        },
        tokens,
      },
    });
  } catch (error) {
    next(error);
  }
};
