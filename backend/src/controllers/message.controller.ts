import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import {
  createMessage,
  getMessagesByBooking,
  getDirectMessages,
  markMessagesAsRead,
  markDirectMessagesAsRead,
  getUnreadMessageCount,
  getConversationList,
<<<<<<< HEAD
  assertBookingMessagingAccess,
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
} from '../services/message.service';

export const sendMessage = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { bookingId, receiverId: bodyReceiverId, content } = req.body;
    const senderId = req.user!._id.toString();
    let receiverId: string;

    if (bookingId) {
      // Auto-resolve receiverId from the booking
      const Booking = (await import('../models/Booking')).default;
      const Technician = (await import('../models/Technician')).default;
      const booking = await Booking.findById(bookingId);
      if (!booking) {
        res.status(404).json({ success: false, message: 'Booking not found' });
        return;
      }
      const bookingUserId = booking.user.toString();
      const bookingTechnicianId = booking.technician.toString();
      if (senderId === bookingUserId) {
        const tech = await Technician.findById(bookingTechnicianId).select('user');
        receiverId = tech ? tech.user.toString() : bookingTechnicianId;
      } else {
        receiverId = bookingUserId;
      }
    } else if (bodyReceiverId) {
      // Direct message — receiverId sent explicitly
      receiverId = bodyReceiverId;
    } else {
      res.status(400).json({ success: false, message: 'bookingId or receiverId is required' });
      return;
    }

    const message = await createMessage({
      bookingId,
      senderId,
      receiverId,
      content,
    });
<<<<<<< HEAD

    if (bookingId) {
      try {
        const { emitBookingMessage } = await import('../socket');
        emitBookingMessage(bookingId, { message });
      } catch (_) {}
    }
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    
    res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: { message },
    });
  } catch (error) {
    next(error);
  }
};

export const getBookingMessages = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { bookingId } = req.params;
    const { page, limit } = req.query;
<<<<<<< HEAD

    await assertBookingMessagingAccess(bookingId as string, req.user!._id.toString(), {
      allowAdminRead: true,
      userRole: req.user!.role,
    });

=======
    
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    const result = await getMessagesByBooking(
      bookingId as string,
      page ? parseInt(page as string) : 1,
      limit ? parseInt(limit as string) : 50
    );
    
    // Mark messages as read
    await markMessagesAsRead(bookingId as string, req.user!._id.toString());
    
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const getMyUnreadCount = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const count = await getUnreadMessageCount(req.user!._id.toString());
    
    res.json({
      success: true,
      data: { unreadCount: count },
    });
  } catch (error) {
    next(error);
  }
};

export const getDirectConversation = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!._id.toString();
    const otherUserId = req.params.userId as string;
    const result = await getDirectMessages(userId, otherUserId);
    
    // Mark direct messages as read (messages from other user to current user)
    await markDirectMessagesAsRead(userId, otherUserId);
    
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

export const getMyConversations = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const conversations = await getConversationList(req.user!._id.toString());
    
    res.json({
      success: true,
      data: { conversations },
    });
  } catch (error) {
    next(error);
  }
};
