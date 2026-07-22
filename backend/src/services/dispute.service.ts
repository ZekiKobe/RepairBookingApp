import Dispute, { IDispute } from '../models/Dispute';
import Booking from '../models/Booking';
import Technician from '../models/Technician';
import { createError } from '../middleware/errorHandler';

export const openDispute = async (data: {
  bookingId: string;
  userId: string;
  reason: string;
  details?: string;
  evidenceUrls?: string[];
}): Promise<IDispute> => {
  const booking = await Booking.findById(data.bookingId);
  if (!booking) throw createError('Booking not found', 404);

  const tech = await Technician.findById(booking.technician);
  const isCustomer = booking.user.toString() === data.userId;
  const isTechUser = tech && tech.user.toString() === data.userId;
  if (!isCustomer && !isTechUser) {
    throw createError('Only booking parties can open a dispute', 403);
  }

  const existing = await Dispute.findOne({ booking: data.bookingId, status: { $in: ['open', 'under_review'] } });
  if (existing) throw createError('An open dispute already exists for this booking', 400);

  return Dispute.create({
    booking: data.bookingId,
    openedBy: data.userId,
    reason: data.reason,
    details: data.details,
    evidenceUrls: data.evidenceUrls,
    status: 'open',
  });
};

export const listDisputesForUser = async (userId: string): Promise<IDispute[]> => {
  return Dispute.find({ openedBy: userId }).sort({ createdAt: -1 }).populate('booking');
};

export const listAllDisputesAdmin = async (): Promise<IDispute[]> => {
  return Dispute.find().sort({ createdAt: -1 }).populate('booking openedBy');
};

export const updateDisputeAdmin = async (
  disputeId: string,
  updates: { status?: 'open' | 'under_review' | 'resolved' | 'dismissed'; resolution?: string }
): Promise<IDispute> => {
  const patch: Record<string, unknown> = {};
  if (updates.status) patch.status = updates.status;
  if (updates.resolution !== undefined) patch.resolution = updates.resolution;
  const d = await Dispute.findByIdAndUpdate(
    disputeId,
    { $set: patch },
    { new: true }
  ).populate('booking openedBy');
  if (!d) throw createError('Dispute not found', 404);
  return d;
};
