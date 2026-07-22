import Message, { IMessage } from '../models/Message';
import Booking from '../models/Booking';
<<<<<<< HEAD
import Technician from '../models/Technician';
import { createError } from '../middleware/errorHandler';

/** Ensures the user may access booking-scoped messages. Admins may read when allowAdminRead is true. */
export const assertBookingMessagingAccess = async (
  bookingId: string,
  userId: string,
  opts?: { allowAdminRead?: boolean; userRole?: string }
): Promise<void> => {
  if (opts?.allowAdminRead && opts?.userRole === 'admin') return;
  const booking = await Booking.findById(bookingId);
  if (!booking) throw createError('Booking not found', 404);
  if (booking.user.toString() === userId) return;
  const tech = await Technician.findById(booking.technician).select('user');
  if (tech && tech.user.toString() === userId) return;
  throw createError('Not authorized to access messages for this booking', 403);
};

=======
import { createError } from '../middleware/errorHandler';

>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
interface CreateMessageData {
  bookingId?: string;
  senderId: string;
  receiverId: string;
  content: string;
}

export const createMessage = async (data: CreateMessageData): Promise<IMessage> => {
  const { bookingId, senderId, receiverId, content } = data;
  
  if (bookingId) {
<<<<<<< HEAD
    await assertBookingMessagingAccess(bookingId, senderId);
=======
    const booking = await Booking.findById(bookingId);
    if (!booking) throw createError('Booking not found', 404);
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  }
  
  const message = await Message.create({
    ...(bookingId ? { booking: bookingId } : {}),
    sender: senderId,
    receiver: receiverId,
    content,
  });
  
  return message.populate([
    { path: 'sender', select: 'firstName lastName avatar' },
    { path: 'receiver', select: 'firstName lastName avatar' },
  ]);
};

export const getDirectMessages = async (
  userId: string,
  otherUserId: string,
  page: number = 1,
  limit: number = 50
): Promise<{ messages: IMessage[]; total: number }> => {
  const filter = {
    booking: { $exists: false },
    $or: [
      { sender: userId, receiver: otherUserId },
      { sender: otherUserId, receiver: userId },
    ],
  };
  const skip = (page - 1) * limit;
  const [messages, total] = await Promise.all([
    Message.find(filter)
      .populate([{ path: 'sender', select: 'firstName lastName avatar' }, { path: 'receiver', select: 'firstName lastName avatar' }])
      .sort({ createdAt: 1 }).skip(skip).limit(limit),
    Message.countDocuments(filter),
  ]);
  return { messages, total };
};

export const getMessagesByBooking = async (
  bookingId: string,
  page: number = 1,
  limit: number = 50
): Promise<{ messages: IMessage[]; total: number; page: number; pages: number }> => {
  const skip = (page - 1) * limit;
  
  const [messages, total] = await Promise.all([
    Message.find({ booking: bookingId })
      .populate([
        { path: 'sender', select: 'firstName lastName avatar' },
        { path: 'receiver', select: 'firstName lastName avatar' },
      ])
      .sort({ createdAt: 1 })
      .skip(skip)
      .limit(limit),
    Message.countDocuments({ booking: bookingId }),
  ]);
  
  return {
    messages,
    total,
    page,
    pages: Math.ceil(total / limit),
  };
};

export const markMessagesAsRead = async (
  bookingId: string,
  userId: string
): Promise<void> => {
  await Message.updateMany(
    {
      booking: bookingId,
      receiver: userId,
      isRead: false,
    },
    {
      isRead: true,
      readAt: new Date(),
    }
  );
};

export const markDirectMessagesAsRead = async (
  userId: string,
  otherUserId: string
): Promise<void> => {
  await Message.updateMany(
    {
      booking: { $exists: false },
      sender: otherUserId,
      receiver: userId,
      isRead: false,
    },
    {
      isRead: true,
      readAt: new Date(),
    }
  );
};

export const getUnreadMessageCount = async (userId: string): Promise<number> => {
  return await Message.countDocuments({
    receiver: userId,
    isRead: false,
  });
};

export const getConversationList = async (
  userId: string
): Promise<Array<{ bookingId: string | null; otherUser: any; lastMessage: IMessage; unreadCount: number }>> => {
  // Fetch all messages involving this user (both booking-based and direct)
  const allMessages = await Message.find({
    $or: [{ sender: userId }, { receiver: userId }],
  })
    .sort({ createdAt: -1 })
    .populate('sender receiver', 'firstName lastName avatar phone');

  // Group by otherUserId so booking-based and direct threads with the
  // same person are merged into a single conversation entry.
  const seen = new Map<string, any>();

  for (const msg of allMessages) {
    const senderId = (msg.sender as any)?._id?.toString() ?? msg.sender?.toString();
    const receiverId = (msg.receiver as any)?._id?.toString() ?? msg.receiver?.toString();
    const otherUser = senderId === userId ? msg.receiver : msg.sender;
    const otherUserId = senderId === userId ? receiverId : senderId;
    const bookingId = msg.booking ? msg.booking.toString() : null;

    // Key is always the other person — merges all channels with same user
    const key = otherUserId;

    if (!seen.has(key)) {
      // Count ALL unread messages from this person regardless of channel
      const unreadCount = await Message.countDocuments({
        sender: otherUserId,
        receiver: userId,
        isRead: false,
      });
      seen.set(key, {
        bookingId,   // bookingId of the most recent message (may be null for direct)
        otherUser,
        lastMessage: msg,
        unreadCount,
      });
    }
  }

  return Array.from(seen.values());
};
