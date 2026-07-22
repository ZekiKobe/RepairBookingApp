import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import {
  openDispute,
  listDisputesForUser,
  listAllDisputesAdmin,
  updateDisputeAdmin,
} from '../services/dispute.service';

export const postDispute = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { bookingId, reason, details, evidenceUrls } = req.body;
    if (!bookingId || !reason) {
      res.status(400).json({ success: false, message: 'bookingId and reason are required' });
      return;
    }
    const d = await openDispute({
      bookingId,
      userId: req.user!._id.toString(),
      reason,
      details,
      evidenceUrls,
    });
    res.status(201).json({ success: true, data: { dispute: d } });
  } catch (error) {
    next(error);
  }
};

export const getMyDisputes = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const list = await listDisputesForUser(req.user!._id.toString());
    res.json({ success: true, data: { disputes: list } });
  } catch (error) {
    next(error);
  }
};

export const getAdminDisputes = async (_req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const list = await listAllDisputesAdmin();
    res.json({ success: true, data: { disputes: list } });
  } catch (error) {
    next(error);
  }
};

export const patchAdminDispute = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const { status, resolution } = req.body;
    const d = await updateDisputeAdmin(id as string, { status, resolution });
    try {
      const { appendAuditLog } = await import('../services/audit.service');
      await appendAuditLog({
        req,
        actorUserId: req.user!._id.toString(),
        action: 'dispute.admin_update',
        targetType: 'dispute',
        targetId: id as string,
        metadata: { status, resolution },
      });
    } catch (_) {}
    res.json({ success: true, data: { dispute: d } });
  } catch (error) {
    next(error);
  }
};
