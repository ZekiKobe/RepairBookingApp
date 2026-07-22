import Notification, { NotificationType } from '../models/Notification';

export const createNotification = async (params: {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  bookingId?: string;
}) => {
  return Notification.create({
    user: params.userId,
    type: params.type,
    title: params.title,
    body: params.body,
    ...(params.bookingId ? { bookingId: params.bookingId } : {}),
  });
};

export const getNotifications = async (userId: string, page = 1, limit = 30) => {
  const skip = (page - 1) * limit;
  const [notifications, total, unreadCount] = await Promise.all([
    Notification.find({ user: userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    Notification.countDocuments({ user: userId }),
    Notification.countDocuments({ user: userId, isRead: false }),
  ]);
  return { notifications, total, unreadCount, page, pages: Math.ceil(total / limit) };
};

export const markAllRead = async (userId: string) => {
  await Notification.updateMany({ user: userId, isRead: false }, { isRead: true });
};

export const markOneRead = async (id: string, userId: string) => {
  await Notification.findOneAndUpdate({ _id: id, user: userId }, { isRead: true });
};

export const getUnreadCount = async (userId: string) => {
  return Notification.countDocuments({ user: userId, isRead: false });
};
