import Estimate, { IEstimate } from '../models/Estimate';
import Technician from '../models/Technician';
import { createError } from '../middleware/errorHandler';

export const createEstimate = async (data: {
  userId: string;
  technicianId: string;
  serviceId: string;
  proposedAmount: number;
  notes?: string;
  photos?: string[];
}): Promise<IEstimate> => {
  const tech = await Technician.findById(data.technicianId);
  if (!tech) throw createError('Technician not found', 404);
  const expiresAt = new Date(Date.now() + 14 * 24 * 60 * 60 * 1000);
  return Estimate.create({
    user: data.userId,
    technician: data.technicianId,
    service: data.serviceId,
    proposedAmount: data.proposedAmount,
    notes: data.notes,
    photos: data.photos,
    status: 'pending',
    expiresAt,
  });
};

export const listEstimatesForUser = async (userId: string): Promise<IEstimate[]> => {
  return Estimate.find({ user: userId })
    .sort({ createdAt: -1 })
    .populate('technician service');
};

export const listEstimatesForTechnicianUser = async (userId: string): Promise<IEstimate[]> => {
  const tech = await Technician.findOne({ user: userId });
  if (!tech) return [];
  return Estimate.find({ technician: tech._id })
    .sort({ createdAt: -1 })
    .populate('user service');
};

export const respondToEstimate = async (
  estimateId: string,
  technicianUserId: string,
  accept: boolean
): Promise<IEstimate> => {
  const tech = await Technician.findOne({ user: technicianUserId });
  if (!tech) throw createError('Technician profile not found', 404);

  const est = await Estimate.findOne({
    _id: estimateId,
    technician: tech._id,
    status: 'pending',
  });
  if (!est) throw createError('Estimate not found or not pending', 404);

  est.status = accept ? 'accepted' : 'rejected';
  await est.save();
  return est.populate(['user', 'technician', 'service']);
};
