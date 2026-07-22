import jwt, { SignOptions } from 'jsonwebtoken';
import User, { IUser } from '../models/User';
import Technician from '../models/Technician';
import { createError } from '../middleware/errorHandler';

interface TokenPayload {
  userId: string;
  role: string;
<<<<<<< HEAD
  adminRole?: string;
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export const generateTokens = (user: IUser): AuthTokens => {
  if (!process.env.JWT_SECRET || !process.env.JWT_REFRESH_SECRET) {
    throw createError('JWT secrets not configured', 500);
  }
  
  const payload: TokenPayload = {
    userId: user._id.toString(),
    role: user.role,
<<<<<<< HEAD
    ...(user.role === 'admin'
      ? { adminRole: (user as IUser & { adminRole?: string }).adminRole ?? 'super_admin' }
      : {}),
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  };
  
  const accessOptions: SignOptions = {
    expiresIn: (process.env.JWT_EXPIRE || '1h') as any,
  };
  
  const refreshOptions: SignOptions = {
    expiresIn: (process.env.JWT_REFRESH_EXPIRE || '7d') as any,
  };
  
  const accessToken = jwt.sign(payload, process.env.JWT_SECRET as string, accessOptions);
  
  const refreshToken = jwt.sign(payload, process.env.JWT_REFRESH_SECRET as string, refreshOptions);
  
  return { accessToken, refreshToken };
};

export const verifyRefreshToken = (refreshToken: string): TokenPayload => {
  if (!process.env.JWT_REFRESH_SECRET) {
    throw createError('JWT refresh secret not configured', 500);
  }
  
  try {
    return jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET as string) as TokenPayload;
  } catch (error) {
    throw createError('Invalid or expired refresh token', 401);
  }
};

export const registerUser = async (userData: {
  phone: string;
  password: string;
  firstName: string;
  lastName: string;
  email?: string;
  role?: 'user' | 'technician';
}): Promise<{ user: IUser; tokens: AuthTokens }> => {
  const { phone, password, firstName, lastName, email, role = 'user' } = userData;
  
  // Check if user exists
  const existingUser = await User.findOne({ phone });
  if (existingUser) {
    throw createError('Phone number already registered', 400);
  }
  
  // Check email if provided
  if (email) {
    const existingEmail = await User.findOne({ email });
    if (existingEmail) {
      throw createError('Email already registered', 400);
    }
  }
  
  // Create user
  const user = await User.create({
    phone,
    password,
    firstName,
    lastName,
    email,
    role,
  });
  
  // If technician, create technician profile
  if (role === 'technician') {
    await Technician.create({
      user: user._id,
      isApproved: false,
    });
  }
  
  const tokens = generateTokens(user);
  
  return { user, tokens };
};

export const loginUser = async (phone: string, password: string): Promise<{ user: IUser; tokens: AuthTokens }> => {
  // Find user with password
  const user = await User.findOne({ phone }).select('+password');
  
  if (!user) {
    throw createError('Invalid credentials', 401);
  }
  
  // Check password
  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    throw createError('Invalid credentials', 401);
  }
  
  if (!user.isActive) {
    throw createError('Account is deactivated', 403);
  }
  
  const tokens = generateTokens(user);
  
  return { user, tokens };
};

export const refreshAccessToken = async (refreshToken: string): Promise<AuthTokens> => {
  const payload = verifyRefreshToken(refreshToken);
  
  const user = await User.findById(payload.userId);
  if (!user || !user.isActive) {
    throw createError('User not found or deactivated', 401);
  }
  
  return generateTokens(user);
};
