import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import {
  createBooking,
  getBookingById,
  getUserBookings,
  getTechnicianBookings,
  updateBookingStatus,
  acceptBooking,
  cancelBooking,
  getBookingStatistics,
  listBookingsForAdmin,
  updateBookingInternalNotes,
  assignBookingTechnician,
} from '../services/booking.service';
import Booking from '../models/Booking';
import Technician from '../models/Technician';
import { createNotification } from '../services/notification.service';
import { sendPushToUser } from '../services/push';

export const createNewBooking = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const {
      technicianId,
      serviceId,
      scheduledDate,
      scheduledTimeSlot,
      description,
      images,
      address,
      location,
      price,
    } = req.body;
    
    const booking = await createBooking({
      userId: req.user!._id.toString(),
      technicianId,
      serviceId,
      scheduledDate: new Date(scheduledDate),
      scheduledTimeSlot,
      description,
      images,
      address,
      location,
      price,
    });
    
    // Notify technician of new booking request
    try {
      const tech = await Technician.findById(booking.technician).select('user');
      if (tech) {
        const techUserId = tech.user.toString();
        await createNotification({
          userId: techUserId,
          type: 'booking_new',
          title: 'New Booking Request',
          body: `You have a new booking request for ${(booking as any).service?.name ?? 'a service'}.`,
          bookingId: booking._id.toString(),
        });
        await sendPushToUser(techUserId, 'New Booking Request', `You have a new booking request for ${(booking as any).service?.name ?? 'a service'}.`);
      }
    } catch (_) {}

    res.status(201).json({
      success: true,
      message: 'Booking created successfully',
      data: { booking },
    });
  } catch (error) {
    next(error);
  }
};

export const getMyBookings = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { status, page, limit } = req.query;
    
    const result = await getUserBookings(
      req.user!._id.toString(),
      status as any,
      page ? parseInt(page as string) : 1,
      limit ? parseInt(limit as string) : 20
    );
    
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const getMyTechnicianBookings = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { status, page, limit } = req.query;
    
    // Get technician profile
    const technician = await Technician.findOne({ user: req.user!._id });
    if (!technician) {
      res.status(404).json({ success: false, message: 'Technician profile not found' });
      return;
    }
    
    const result = await getTechnicianBookings(
      technician._id.toString(),
      status as any,
      page ? parseInt(page as string) : 1,
      limit ? parseInt(limit as string) : 20
    );
    
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const getBooking = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const booking = await getBookingById(id as string);
    
    // Verify user has access to this booking
    const userId = req.user!._id.toString();
    const isUser = booking.user._id.toString() === userId;
    const isTechnician = (booking.technician as any).user?.toString() === userId;
    const isAdmin = req.user!.role === 'admin';
    
    if (!isUser && !isTechnician && !isAdmin) {
      res.status(403).json({ success: false, message: 'Access denied' });
      return;
    }
    
    res.json({
      success: true,
      data: { booking },
    });
  } catch (error) {
    next(error);
  }
};

export const updateStatus = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;
    
    // Get booking to verify access
    const booking = await Booking.findById(id);
    if (!booking) {
      res.status(404).json({ success: false, message: 'Booking not found' });
      return;
    }
    
    const userId = req.user!._id.toString();
    const isTechnician = booking.technician.toString() === userId || 
      (await Technician.exists({ _id: booking.technician, user: userId }));
    const isAdmin = req.user!.role === 'admin';
    
    // Only technician or admin can update status
    if (!isTechnician && !isAdmin) {
      res.status(403).json({ success: false, message: 'Access denied' });
      return;
    }
    
    const updatedBooking = await updateBookingStatus(id as string, status, notes);

    // Notify customer of status changes
    try {
      const customerId = (updatedBooking as any).user?._id?.toString() ?? updatedBooking.user.toString();
      if (status === 'in_progress') {
        await createNotification({ userId: customerId, type: 'booking_in_progress', title: 'Job Started', body: 'The technician has started working on your booking.', bookingId: updatedBooking._id.toString() });
        await sendPushToUser(customerId, 'Job Started', 'The technician has started working on your booking.');
      } else if (status === 'completed') {
        await createNotification({ userId: customerId, type: 'booking_completed', title: 'Job Completed', body: 'Your booking has been marked as completed. Please rate your experience.', bookingId: updatedBooking._id.toString() });
        await sendPushToUser(customerId, 'Job Completed', 'Your booking has been marked as completed. Please rate your experience.');
      }
    } catch (_) {}

    res.json({
      success: true,
      message: 'Booking status updated successfully',
      data: { booking: updatedBooking },
    });
  } catch (error) {
    next(error);
  }
};

export const acceptBookingRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    
    // Get technician profile
    const technician = await Technician.findOne({ user: req.user!._id });
    if (!technician) {
      res.status(404).json({ success: false, message: 'Technician profile not found' });
      return;
    }
    
    const booking = await acceptBooking(id as string, technician._id.toString());

    // Notify customer that booking was accepted
    try {
      const acceptCustomerId = (booking as any).user?._id?.toString() ?? booking.user.toString();
      await createNotification({
        userId: acceptCustomerId,
        type: 'booking_accepted',
        title: 'Booking Accepted',
        body: 'Your booking has been accepted by the technician.',
        bookingId: booking._id.toString(),
      });
      await sendPushToUser(acceptCustomerId, 'Booking Accepted', 'Your booking has been accepted by the technician.');
    } catch (_) {}

    res.json({
      success: true,
      message: 'Booking accepted successfully',
      data: { booking },
    });
  } catch (error) {
    next(error);
  }
};

export const cancelBookingRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    
    // Get booking to verify access
    const booking = await Booking.findById(id);
    if (!booking) {
      res.status(404).json({ success: false, message: 'Booking not found' });
      return;
    }
    
    const userId = req.user!._id.toString();
    const isUser = booking.user.toString() === userId;
    const isTechnician = await Technician.exists({ _id: booking.technician, user: userId });
    const isAdmin = req.user!.role === 'admin';
    
    if (!isUser && !isTechnician && !isAdmin) {
      res.status(403).json({ success: false, message: 'Access denied' });
      return;
    }
    
    const cancelledBy: 'user' | 'technician' | 'admin' = isAdmin ? 'admin' : isUser ? 'user' : 'technician';
    const cancelledBooking = await cancelBooking(id as string, cancelledBy, reason);

    // Notify the other party
    try {
      if (cancelledBy === 'user') {
        // Notify technician
        const tech = await Technician.findById(booking.technician).select('user');
        if (tech) {
          const cancelTechUserId = tech.user.toString();
          await createNotification({ userId: cancelTechUserId, type: 'booking_cancelled', title: 'Booking Cancelled', body: 'A customer has cancelled their booking.', bookingId: booking._id.toString() });
          await sendPushToUser(cancelTechUserId, 'Booking Cancelled', 'A customer has cancelled their booking.');
        }
      } else if (cancelledBy === 'technician') {
        // Notify customer
        const cancelCustomerId = booking.user.toString();
        await createNotification({ userId: cancelCustomerId, type: 'booking_cancelled', title: 'Booking Cancelled', body: 'The technician has cancelled your booking.', bookingId: booking._id.toString() });
        await sendPushToUser(cancelCustomerId, 'Booking Cancelled', 'The technician has cancelled your booking.');
      } else {
        const cancelCustomerId = booking.user.toString();
        const tech = await Technician.findById(booking.technician).select('user');
        const cancelTechUserId = tech?.user.toString();
        const msg = 'This booking was cancelled by an administrator.';
        await createNotification({ userId: cancelCustomerId, type: 'booking_cancelled', title: 'Booking Cancelled', body: msg, bookingId: booking._id.toString() });
        await sendPushToUser(cancelCustomerId, 'Booking Cancelled', msg);
        if (cancelTechUserId) {
          await createNotification({ userId: cancelTechUserId, type: 'booking_cancelled', title: 'Booking Cancelled', body: msg, bookingId: booking._id.toString() });
          await sendPushToUser(cancelTechUserId, 'Booking Cancelled', msg);
        }
      }
    } catch (_) {}

    res.json({
      success: true,
      message: 'Booking cancelled successfully',
      data: { booking: cancelledBooking },
    });
  } catch (error) {
    next(error);
  }
};

export const getMyStatistics = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    // Get technician profile
    const technician = await Technician.findOne({ user: req.user!._id });
    if (!technician) {
      res.status(404).json({ success: false, message: 'Technician profile not found' });
      return;
    }
    
    const stats = await getBookingStatistics(technician._id.toString());
    
    res.json({
      success: true,
      data: { statistics: stats },
    });
  } catch (error) {
    next(error);
  }
};

// Admin
export const getAllBookings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
    const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;
    const status = req.query.status as import('../models/Booking').BookingStatus | undefined;
    const paymentStatus = req.query.paymentStatus as import('../models/Booking').PaymentStatus | undefined;
    const technicianId = req.query.technicianId as string | undefined;
    const userId = req.query.userId as string | undefined;
    const search = req.query.search as string | undefined;
    const from = req.query.from ? new Date(req.query.from as string) : undefined;
    const to = req.query.to ? new Date(req.query.to as string) : undefined;
    const sort = (req.query.sort as 'createdAt' | 'scheduledDate' | 'price' | undefined) ?? 'createdAt';
    const order = (req.query.order as 'asc' | 'desc' | undefined) ?? 'desc';

    const result = await listBookingsForAdmin({
      status,
      paymentStatus,
      technicianId,
      userId,
      from,
      to,
      search,
      page,
      limit,
      sort,
      order,
    });

    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const adminUpdateBookingNotes = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const id = String(req.params.id);
    const { notes } = req.body as { notes?: string };
    if (notes === undefined) {
      res.status(400).json({ success: false, message: 'notes is required' });
      return;
    }
    const booking = await updateBookingInternalNotes(id, notes);
    res.json({ success: true, data: { booking } });
  } catch (error) {
    next(error);
  }
};

export const adminAssignBookingTechnician = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const id = String(req.params.id);
    const { technicianId } = req.body as { technicianId?: string };
    if (!technicianId) {
      res.status(400).json({ success: false, message: 'technicianId is required' });
      return;
    }
    const booking = await assignBookingTechnician(id, technicianId);
    res.json({ success: true, data: { booking } });
  } catch (error) {
    next(error);
  }
};

export const getAdminStatistics = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const stats = await getBookingStatistics();
    
    res.json({
      success: true,
      data: { statistics: stats },
    });
  } catch (error) {
    next(error);
  }
};

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

export const getBookingInvoice = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const booking = await getBookingById(id as string);
    const userId = req.user!._id.toString();
    const isUser = (booking.user as any)._id.toString() === userId;
    const isTechnician = (booking.technician as any).user?.toString() === userId;
    const isAdmin = req.user!.role === 'admin';
    if (!isUser && !isTechnician && !isAdmin) {
      res.status(403).json({ success: false, message: 'Access denied' });
      return;
    }
    const u = booking.user as any;
    const svc = booking.service as any;
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.send(
      `<!DOCTYPE html><html><head><meta charset="utf-8"><title>Invoice</title></head><body>
<h1>Service receipt</h1>
<p><strong>Booking:</strong> ${booking._id}</p>
<p><strong>Customer:</strong> ${escapeHtml(`${u.firstName ?? ''} ${u.lastName ?? ''}`)}</p>
<p><strong>Service:</strong> ${escapeHtml(svc?.name ?? '')}</p>
<p><strong>Amount:</strong> ETB ${booking.price}</p>
<p><strong>Payment:</strong> ${escapeHtml(booking.paymentStatus)}</p>
<p><strong>Status:</strong> ${escapeHtml(booking.status)}</p>
<p><em>Generated ${new Date().toISOString()}</em></p>
</body></html>`
    );
  } catch (error) {
    next(error);
  }
};
