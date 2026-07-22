import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { getNotifications, markAllRead, markOneRead, getUnreadCount } from '../services/notification.service';

export const getMyNotifications = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { page, limit } = req.query;
    const result = await getNotifications(
      req.user!._id.toString(),
      page ? parseInt(page as string) : 1,
      limit ? parseInt(limit as string) : 30
    );
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

export const getMyUnreadCount = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const count = await getUnreadCount(req.user!._id.toString());
    res.json({ success: true, data: { unreadCount: count } });
  } catch (error) {
    next(error);
  }
};

export const markAllAsRead = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    await markAllRead(req.user!._id.toString());
    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    next(error);
  }
};

export const markOneAsRead = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    await markOneRead(req.params.id as string, req.user!._id.toString());
    res.json({ success: true, message: 'Notification marked as read' });
  } catch (error) {
    next(error);
  }
};
