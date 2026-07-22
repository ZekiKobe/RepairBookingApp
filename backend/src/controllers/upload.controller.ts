import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { getStorageProvider } from '../services/storage';

export const uploadAvatar = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.file) {
      res.status(400).json({ success: false, message: 'No file provided' });
      return;
    }

    const result = await getStorageProvider().upload(
      req.file.buffer,
      req.file.originalname,
      req.file.mimetype,
      'avatars'
    );

    // Update user avatar URL
    const User = (await import('../models/User')).default;
    await User.findByIdAndUpdate(req.user!._id, { avatar: result.url });

    res.json({
      success: true,
      message: 'Avatar uploaded successfully',
      data: { url: result.url },
    });
  } catch (error) {
    next(error);
  }
};

export const uploadAttachment = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.file) {
      res.status(400).json({ success: false, message: 'No file provided' });
      return;
    }

    const result = await getStorageProvider().upload(
      req.file.buffer,
      req.file.originalname,
      req.file.mimetype,
      'attachments'
    );

    res.json({
      success: true,
      message: 'File uploaded successfully',
      data: { url: result.url, publicId: result.publicId },
    });
  } catch (error) {
    next(error);
  }
};
