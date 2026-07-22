import { Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import Booking from '../models/Booking';
import Technician from '../models/Technician';
import PlatformSettings from '../models/PlatformSettings';
import NotificationTemplate from '../models/NotificationTemplate';
import User from '../models/User';
import { listLedgerEntries } from '../services/ledger.service';
import { createNotification } from '../services/notification.service';
import { appendAuditLog } from '../services/audit.service';
import { AuthRequest } from '../middleware/auth';

function defaultPlatformSections() {
  return {
    general: { companyName: 'Repair Booking', supportEmail: '', timezone: 'Africa/Addis_Ababa' },
    branding: { primaryColor: '#0f172a', logoUrl: '' },
    booking: { defaultSlotMinutes: 60, maxAdvanceDays: 30 },
    payments: { defaultCurrency: 'ETB' },
    tax: { ratePercent: 0, inclusive: false },
    notifications: { pushEnabled: true, emailEnabled: false },
    security: { sessionTimeoutMinutes: 60, minPasswordLength: 6 },
    maintenance: { enabled: false, message: '' },
    mfa: { enabled: false, enforcedForAdmins: false },
  };
}

function buildBookingMatch(req: Request): Record<string, unknown> {
  const match: Record<string, unknown> = {};
  if (req.query.from || req.query.to) {
    const range: Record<string, Date> = {};
    if (req.query.from) range.$gte = new Date(req.query.from as string);
    if (req.query.to) range.$lte = new Date(req.query.to as string);
    match.createdAt = range;
  }
  if (req.query.technicianId) match.technician = new mongoose.Types.ObjectId(req.query.technicianId as string);
  if (req.query.userId) match.user = new mongoose.Types.ObjectId(req.query.userId as string);
  if (req.query.status) match.status = req.query.status;
  if (req.query.serviceId) match.service = new mongoose.Types.ObjectId(req.query.serviceId as string);
  return match;
}

export const getDashboardAnalytics = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const match = buildBookingMatch(req);
    const [byMonth, paymentMix, byService, techPerf, turnaround] = await Promise.all([
      Booking.aggregate([
        { $match: match },
        {
          $group: {
            _id: { y: { $year: '$createdAt' }, m: { $month: '$createdAt' } },
            bookings: { $sum: 1 },
            revenue: {
              $sum: {
                $cond: [{ $and: [{ $eq: ['$status', 'completed'] }, { $eq: ['$paymentStatus', 'paid'] }] }, '$price', 0],
              },
            },
          },
        },
        { $sort: { '_id.y': 1, '_id.m': 1 } },
        { $limit: 36 },
      ]),
      Booking.aggregate([{ $match: match }, { $group: { _id: '$paymentStatus', count: { $sum: 1 } } }]),
      Booking.aggregate([
        { $match: match },
        { $lookup: { from: 'services', localField: 'service', foreignField: '_id', as: 'svc' } },
        { $unwind: { path: '$svc', preserveNullAndEmptyArrays: true } },
        { $group: { _id: '$svc.name', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 12 },
      ]),
      Booking.aggregate([
        { $match: { ...match, status: 'completed' } },
        {
          $group: {
            _id: '$technician',
            completed: { $sum: 1 },
            revenue: { $sum: '$price' },
          },
        },
        { $sort: { completed: -1 } },
        { $limit: 10 },
        { $lookup: { from: 'technicians', localField: '_id', foreignField: '_id', as: 't' } },
        { $unwind: { path: '$t', preserveNullAndEmptyArrays: true } },
        { $lookup: { from: 'users', localField: 't.user', foreignField: '_id', as: 'u' } },
        { $unwind: { path: '$u', preserveNullAndEmptyArrays: true } },
        {
          $project: {
            technicianId: '$_id',
            completed: 1,
            revenue: 1,
            techName: { $concat: [{ $ifNull: ['$u.firstName', ''] }, ' ', { $ifNull: ['$u.lastName', ''] }] },
          },
        },
      ]),
      Booking.aggregate([
        { $match: { ...match, status: 'completed', completedAt: { $exists: true } } },
        {
          $project: {
            hours: { $divide: [{ $subtract: ['$completedAt', '$createdAt'] }, 1000 * 60 * 60] },
          },
        },
        { $group: { _id: null, avgHours: { $avg: '$hours' } } },
      ]),
    ]);

    res.json({
      success: true,
      data: {
        byMonth,
        paymentMix,
        byService,
        techPerf,
        avgTurnaroundHours: turnaround[0]?.avgHours ?? null,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const listFinanceLedger = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
    const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 30;
    const rawType = req.query.type as string | undefined;
    const allowed = ['payment', 'refund', 'payout', 'adjustment'] as const;
    const type = rawType && (allowed as readonly string[]).includes(rawType) ? (rawType as (typeof allowed)[number]) : undefined;
    const bookingId = req.query.bookingId as string | undefined;
    const from = req.query.from ? new Date(req.query.from as string) : undefined;
    const to = req.query.to ? new Date(req.query.to as string) : undefined;
    const result = await listLedgerEntries({ page, limit, type, bookingId, from, to });
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

export const getPlatformSettings = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    let doc = await PlatformSettings.findOne({ key: 'platform' });
    if (!doc) {
      const d = defaultPlatformSections();
      doc = await PlatformSettings.create({ key: 'platform', ...d });
    }
    res.json({
      success: true,
      data: {
        general: doc.general,
        branding: doc.branding,
        booking: doc.booking,
        payments: doc.payments,
        tax: doc.tax,
        notifications: doc.notifications,
        security: doc.security,
        maintenance: doc.maintenance,
        mfa: doc.mfa,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const putPlatformSettings = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const body = req.body as Record<string, Record<string, unknown>>;
    const keys = ['general', 'branding', 'booking', 'payments', 'tax', 'notifications', 'security', 'maintenance', 'mfa'] as const;
    const update: Record<string, unknown> = {};
    for (const k of keys) {
      if (body[k] && typeof body[k] === 'object') update[k] = { ...body[k] };
    }
    const doc = await PlatformSettings.findOneAndUpdate(
      { key: 'platform' },
      { $set: update, $setOnInsert: { key: 'platform', ...defaultPlatformSections() } },
      { new: true, upsert: true }
    );
    await appendAuditLog({
      req,
      actorUserId: req.user?._id.toString(),
      action: 'settings.update',
      targetType: 'PlatformSettings',
      targetId: 'platform',
      metadata: { keys: Object.keys(update) },
    });
    res.json({
      success: true,
      message: 'Settings updated',
      data: {
        general: doc!.general,
        branding: doc!.branding,
        booking: doc!.booking,
        payments: doc!.payments,
        tax: doc!.tax,
        notifications: doc!.notifications,
        security: doc!.security,
        maintenance: doc!.maintenance,
        mfa: doc!.mfa,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const listNotificationTemplates = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const items = await NotificationTemplate.find().sort({ updatedAt: -1 });
    res.json({ success: true, data: { templates: items } });
  } catch (error) {
    next(error);
  }
};

export const createNotificationTemplate = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const t = await NotificationTemplate.create(req.body);
    await appendAuditLog({
      req,
      actorUserId: req.user?._id.toString(),
      action: 'notification_template.create',
      targetType: 'NotificationTemplate',
      targetId: t._id.toString(),
    });
    res.status(201).json({ success: true, data: { template: t } });
  } catch (error) {
    next(error);
  }
};

export const updateNotificationTemplate = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const t = await NotificationTemplate.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!t) {
      res.status(404).json({ success: false, message: 'Template not found' });
      return;
    }
    await appendAuditLog({
      req,
      actorUserId: req.user?._id.toString(),
      action: 'notification_template.update',
      targetType: 'NotificationTemplate',
      targetId: t._id.toString(),
    });
    res.json({ success: true, data: { template: t } });
  } catch (error) {
    next(error);
  }
};

export const deleteNotificationTemplate = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    await NotificationTemplate.findByIdAndDelete(req.params.id);
    await appendAuditLog({
      req,
      actorUserId: req.user?._id.toString(),
      action: 'notification_template.delete',
      targetType: 'NotificationTemplate',
      targetId: typeof req.params.id === 'string' ? req.params.id : req.params.id?.[0],
    });
    res.json({ success: true, message: 'Deleted' });
  } catch (error) {
    next(error);
  }
};

export const broadcastNotification = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { title, body, audience } = req.body as { title: string; body: string; audience?: 'users' | 'technicians' | 'all' };
    if (!title?.trim() || !body?.trim()) {
      res.status(400).json({ success: false, message: 'title and body are required' });
      return;
    }
    const aud = audience ?? 'all';
    const roleFilter =
      aud === 'users' ? { role: 'user' } : aud === 'technicians' ? { role: 'technician' } : { role: { $in: ['user', 'technician'] } };
    const users = await User.find({ ...roleFilter, isActive: true }).select('_id').lean();
    const batch = users.map((u) => ({
      user: u._id,
      type: 'announcement' as const,
      title: title.trim(),
      body: body.trim(),
    }));
    if (batch.length) {
      const Notification = (await import('../models/Notification')).default;
      await Notification.insertMany(batch);
    }
    await appendAuditLog({
      req,
      actorUserId: req.user?._id.toString(),
      action: 'notification.broadcast',
      metadata: { audience: aud, count: batch.length },
    });
    res.json({ success: true, data: { sent: batch.length } });
  } catch (error) {
    next(error);
  }
};

export const getTechnicianSuggestions = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const serviceId = req.query.serviceId as string | undefined;
    const filter: Record<string, unknown> = { isApproved: true, isSuspended: { $ne: true } };
    if (serviceId) {
      filter['services.service'] = new mongoose.Types.ObjectId(serviceId);
    }
    const techs = await Technician.find(filter)
      .populate({ path: 'user', select: 'firstName lastName phone' })
      .sort({ rating: -1, totalJobs: -1 })
      .limit(20);
    res.json({ success: true, data: { technicians: techs } });
  } catch (error) {
    next(error);
  }
};
