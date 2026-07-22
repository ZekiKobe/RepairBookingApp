import { Request, Response, NextFunction } from 'express';
import { updateUser, updateLocation, getUserById, searchUsers } from '../services/user.service';
import { AuthRequest } from '../middleware/auth';
import User from '../models/User';

export const getProfile = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await getUserById(req.user!._id.toString());
    
    res.json({
      success: true,
      data: { user },
    });
  } catch (error) {
    next(error);
  }
};

export const updateProfile = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const updates = req.body;
    const user = await updateUser(req.user!._id.toString(), updates);
    
    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: { user },
    });
  } catch (error) {
    next(error);
  }
};

export const setLocation = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { coordinates, address } = req.body;
    
    const location = {
      type: 'Point' as const,
      coordinates,
      address,
    };
    
    const user = await updateLocation(req.user!._id.toString(), location);
    
    res.json({
      success: true,
      message: 'Location updated successfully',
      data: { location: user.location },
    });
  } catch (error) {
    next(error);
  }
};

// Admin only
export const getAllUsers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { phone, email, role, isActive, page, limit } = req.query;
    
    const result = await searchUsers({
      phone: phone as string,
      email: email as string,
      role: role as string,
      isActive: isActive !== undefined ? isActive === 'true' : undefined,
      page: page ? parseInt(page as string) : 1,
      limit: limit ? parseInt(limit as string) : 20,
    });
    
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const getUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const user = await getUserById(id as string);
    
    res.json({
      success: true,
      data: { user },
    });
  } catch (error) {
    next(error);
  }
};

export const updateFcmToken = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken) {
      res.status(400).json({ success: false, message: 'fcmToken is required' });
      return;
    }
    await User.findByIdAndUpdate(req.user!._id, { fcmToken });
    res.json({ success: true, message: 'FCM token updated' });
  } catch (error) {
    next(error);
  }
};

export const exportMyData = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { buildPersonalDataExport } = await import('../services/dataExport.service');
    const data = await buildPersonalDataExport(req.user!._id.toString());
    res.json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

export const deleteMyAccount = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { softDeleteUserAccount } = await import('../services/dataExport.service');
    await softDeleteUserAccount(req.user!._id.toString());
    res.json({ success: true, message: 'Account deactivated and personal identifiers removed' });
  } catch (error) {
    next(error);
  }
};

export const recordConsents = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { marketing, analytics, location, policyVersion } = req.body;
    if (!policyVersion || typeof policyVersion !== 'string') {
      res.status(400).json({ success: false, message: 'policyVersion is required' });
      return;
    }
    const ConsentLog = (await import('../models/ConsentLog')).default;
    await ConsentLog.create({
      user: req.user!._id,
      marketing: Boolean(marketing),
      analytics: Boolean(analytics),
      location: Boolean(location),
      policyVersion,
    });
    res.json({ success: true, message: 'Consent recorded' });
  } catch (error) {
    next(error);
  }
};
