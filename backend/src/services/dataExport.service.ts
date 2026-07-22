import User from '../models/User';
import Booking from '../models/Booking';
import Message from '../models/Message';
import Notification from '../models/Notification';
import Review from '../models/Review';
import { createError } from '../middleware/errorHandler';

export async function buildPersonalDataExport(userId: string): Promise<Record<string, unknown>> {
  const user = await User.findById(userId).select('-password').lean();
  if (!user) throw createError('User not found', 404);

  const [bookings, messages, notifications, reviews] = await Promise.all([
    Booking.find({ user: userId }).lean(),
    Message.find({ $or: [{ sender: userId }, { receiver: userId }] })
      .sort({ createdAt: -1 })
      .limit(2000)
      .lean(),
    Notification.find({ user: userId }).sort({ createdAt: -1 }).limit(500).lean(),
    Review.find({ user: userId }).sort({ createdAt: -1 }).limit(500).lean(),
  ]);

  return {
    exportedAt: new Date().toISOString(),
    user,
    bookings,
    messages,
    notifications,
    reviews,
  };
}

export async function softDeleteUserAccount(userId: string): Promise<void> {
  const user = await User.findById(userId);
  if (!user) throw createError('User not found', 404);
  user.isActive = false;
  user.phone = `deleted_${userId}_${Date.now()}`;
  user.email = undefined;
  user.fcmToken = undefined;
  user.googleUid = undefined;
  user.firstName = 'Deleted';
  user.lastName = 'User';
  user.location = undefined;
  await user.save({ validateModifiedOnly: true });
}
