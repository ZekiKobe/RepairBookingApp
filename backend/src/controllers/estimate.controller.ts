import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import {
  createEstimate,
  listEstimatesForUser,
  listEstimatesForTechnicianUser,
  respondToEstimate,
} from '../services/estimate.service';

export const postEstimate = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { technicianId, serviceId, proposedAmount, notes, photos } = req.body;
    if (!technicianId || !serviceId || proposedAmount == null) {
      res.status(400).json({ success: false, message: 'technicianId, serviceId, and proposedAmount are required' });
      return;
    }
    const est = await createEstimate({
      userId: req.user!._id.toString(),
      technicianId,
      serviceId,
      proposedAmount: Number(proposedAmount),
      notes,
      photos,
    });
    res.status(201).json({ success: true, data: { estimate: est } });
  } catch (error) {
    next(error);
  }
};

export const getMyEstimates = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const list = await listEstimatesForUser(req.user!._id.toString());
    res.json({ success: true, data: { estimates: list } });
  } catch (error) {
    next(error);
  }
};

export const getTechnicianEstimates = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const list = await listEstimatesForTechnicianUser(req.user!._id.toString());
    res.json({ success: true, data: { estimates: list } });
  } catch (error) {
    next(error);
  }
};

export const putRespondEstimate = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const accept = Boolean(req.body?.accept);
    const est = await respondToEstimate(id as string, req.user!._id.toString(), accept);
    res.json({ success: true, data: { estimate: est } });
  } catch (error) {
    next(error);
  }
};
