import { Request, Response, NextFunction } from 'express';
import User from '../models/User';
import Technician from '../models/Technician';
import Booking from '../models/Booking';
import Review from '../models/Review';
import Service from '../models/Service';

export const getDashboardStats = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const [
      totalUsers,
      totalTechnicians,
      pendingTechnicians,
      totalBookings,
      totalServices,
      totalReviews,
      recentBookings,
    ] = await Promise.all([
      User.countDocuments({ role: 'user' }),
      Technician.countDocuments(),
      Technician.countDocuments({ isApproved: false }),
      Booking.countDocuments(),
      Service.countDocuments(),
      Review.countDocuments(),
      Booking.find()
        .sort({ createdAt: -1 })
        .limit(5)
        .populate([
          { path: 'user', select: 'firstName lastName phone' },
          { path: 'technician', populate: { path: 'user', select: 'firstName lastName' } },
          { path: 'service', select: 'name' },
        ]),
    ]);
    
    // Get booking status breakdown
    const bookingStats = await Booking.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
        },
      },
    ]);
    
    const statusBreakdown = bookingStats.reduce((acc, stat) => {
      acc[stat._id] = stat.count;
      return acc;
    }, {});
    
    // Calculate total earnings
    const earnings = await Booking.aggregate([
      { $match: { status: 'completed', paymentStatus: 'paid' } },
      { $group: { _id: null, total: { $sum: '$price' } } },
    ]);
    
    res.json({
      success: true,
      data: {
        stats: {
          totalUsers,
          totalTechnicians,
          pendingTechnicians,
          totalBookings,
          totalServices,
          totalReviews,
          totalEarnings: earnings[0]?.total || 0,
        },
        bookingStatusBreakdown: statusBreakdown,
        recentBookings,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getAllUsersAdmin = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { role, isActive, page = 1, limit = 20 } = req.query;
    
    const filter: any = {};
    if (role) filter.role = role;
    if (isActive !== undefined) filter.isActive = isActive === 'true';
    
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);
    
    const [users, total] = await Promise.all([
      User.find(filter)
        .select('-password')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit as string)),
      User.countDocuments(filter),
    ]);
    
    res.json({
      success: true,
      data: {
        users,
        total,
        page: parseInt(page as string),
        pages: Math.ceil(total / parseInt(limit as string)),
      },
    });
  } catch (error) {
    next(error);
  }
};

export const toggleUserStatus = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const user = await User.findById(id);
    
    if (!user) {
      res.status(404).json({ success: false, message: 'User not found' });
      return;
    }
    
    user.isActive = !user.isActive;
    await user.save();
    
    res.json({
      success: true,
      message: `User ${user.isActive ? 'activated' : 'deactivated'} successfully`,
      data: { user },
    });
  } catch (error) {
    next(error);
  }
};

export const getAuditLogs = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { listAuditLogsQuery } = await import('../services/audit.service');
    const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
    const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 50;
    const action = req.query.action as string | undefined;
    const targetType = req.query.targetType as string | undefined;
    const actorUserId = req.query.actorUserId as string | undefined;
    const from = req.query.from ? new Date(req.query.from as string) : undefined;
    const to = req.query.to ? new Date(req.query.to as string) : undefined;
    const result = await listAuditLogsQuery({ page, limit, action, targetType, actorUserId, from, to });
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};
