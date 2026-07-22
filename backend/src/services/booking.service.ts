import Booking, { IBooking, BookingStatus } from '../models/Booking';
import Technician from '../models/Technician';
import { createError } from '../middleware/errorHandler';
import mongoose from 'mongoose';

interface CreateBookingData {
  userId: string;
  technicianId: string;
  serviceId: string;
  scheduledDate: Date;
  scheduledTimeSlot: { start: string; end: string };
  description?: string;
  images?: string[];
  address: string;
  location?: { lat: number; lng: number };
  price: number;
}

export const createBooking = async (data: CreateBookingData): Promise<IBooking> => {
  const {
    userId,
    technicianId,
    serviceId,
    scheduledDate,
    scheduledTimeSlot,
    description,
    images,
    address,
    location,
    price,
  } = data;
  
  // Check if technician exists and is approved
  const technician = await Technician.findById(technicianId);
  if (!technician) {
    throw createError('Technician not found', 404);
  }
  if (!technician.isApproved) {
    throw createError('Technician is not approved', 400);
  }
  
  const bookingData: any = {
    user: userId,
    technician: technicianId,
    service: serviceId,
    scheduledDate,
    scheduledTimeSlot,
    description,
    images,
    address,
    price,
    status: 'pending',
  };
  
  if (location) {
    bookingData.location = {
      type: 'Point',
      coordinates: [location.lng, location.lat],
    };
  }
  
  const booking = await Booking.create(bookingData);
  
  return booking.populate([
    { path: 'user', select: '-password' },
    { path: 'technician', populate: { path: 'user', select: '-password' } },
    { path: 'service' },
  ]);
};

export const getBookingById = async (bookingId: string): Promise<IBooking> => {
  const booking = await Booking.findById(bookingId).populate([
    { path: 'user', select: '-password' },
    { path: 'technician', populate: { path: 'user', select: '-password' } },
    { path: 'service' },
  ]);
  
  if (!booking) {
    throw createError('Booking not found', 404);
  }
  
  return booking;
};

export const getUserBookings = async (
  userId: string,
  status?: BookingStatus,
  page: number = 1,
  limit: number = 20
): Promise<{ bookings: IBooking[]; total: number; page: number; pages: number }> => {
  const filter: any = { user: userId };
  if (status) filter.status = status;
  
  const skip = (page - 1) * limit;
  
  const [bookings, total] = await Promise.all([
    Booking.find(filter)
      .populate([
        { path: 'technician', populate: { path: 'user', select: '-password' } },
        { path: 'service' },
      ])
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    Booking.countDocuments(filter),
  ]);
  
  return {
    bookings,
    total,
    page,
    pages: Math.ceil(total / limit),
  };
};

export const getTechnicianBookings = async (
  technicianId: string,
  status?: BookingStatus,
  page: number = 1,
  limit: number = 20
): Promise<{ bookings: IBooking[]; total: number; page: number; pages: number }> => {
  const filter: any = { technician: technicianId };
  if (status) filter.status = status;
  
  const skip = (page - 1) * limit;
  
  const [bookings, total] = await Promise.all([
    Booking.find(filter)
      .populate([
        { path: 'user', select: '-password' },
        { path: 'service' },
      ])
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    Booking.countDocuments(filter),
  ]);
  
  return {
    bookings,
    total,
    page,
    pages: Math.ceil(total / limit),
  };
};

export const updateBookingStatus = async (
  bookingId: string,
  status: BookingStatus,
  notes?: string
): Promise<IBooking> => {
  const updateData: any = { status };
  
  if (status === 'completed') {
    updateData.completedAt = new Date();
  }
  if (notes) {
    updateData.notes = notes;
  }
  
  const booking = await Booking.findByIdAndUpdate(
    bookingId,
    updateData,
    { new: true }
  ).populate([
    { path: 'user', select: '-password' },
    { path: 'technician', populate: { path: 'user', select: '-password' } },
    { path: 'service' },
  ]);
  
  if (!booking) {
    throw createError('Booking not found', 404);
  }
  
  return booking;
};

export const acceptBooking = async (
  bookingId: string,
  technicianId: string
): Promise<IBooking> => {
  const booking = await Booking.findOne({
    _id: bookingId,
    technician: technicianId,
    status: 'pending',
  });
  
  if (!booking) {
    throw createError('Booking not found or already processed', 404);
  }
  
  booking.status = 'accepted';
  await booking.save();
  
  return booking.populate([
    { path: 'user', select: '-password' },
    { path: 'technician', populate: { path: 'user', select: '-password' } },
    { path: 'service' },
  ]);
};

export const cancelBooking = async (
  bookingId: string,
<<<<<<< HEAD
  cancelledBy: 'user' | 'technician' | 'admin',
=======
  cancelledBy: 'user' | 'technician',
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  reason?: string
): Promise<IBooking> => {
  const booking = await Booking.findById(bookingId);
  
  if (!booking) {
    throw createError('Booking not found', 404);
  }
  
  if (booking.status === 'cancelled') {
    throw createError('Booking is already cancelled', 400);
  }
  
  if (booking.status === 'completed') {
    throw createError('Cannot cancel a completed booking', 400);
  }
  
  booking.status = 'cancelled';
  booking.cancelledBy = cancelledBy;
  booking.cancellationReason = reason;
  
  await booking.save();
  
  return booking.populate([
    { path: 'user', select: '-password' },
    { path: 'technician', populate: { path: 'user', select: '-password' } },
    { path: 'service' },
  ]);
};

export const getBookingStatistics = async (technicianId?: string): Promise<any> => {
  const matchStage: any = {};
  if (technicianId) {
    matchStage.technician = new mongoose.Types.ObjectId(technicianId);
  }
  
  const stats = await Booking.aggregate([
    { $match: matchStage },
    {
      $group: {
        _id: null,
        total: { $sum: 1 },
        pending: { $sum: { $cond: [{ $eq: ['$status', 'pending'] }, 1, 0] } },
        accepted: { $sum: { $cond: [{ $eq: ['$status', 'accepted'] }, 1, 0] } },
        onTheWay: { $sum: { $cond: [{ $eq: ['$status', 'on_the_way'] }, 1, 0] } },
        inProgress: { $sum: { $cond: [{ $eq: ['$status', 'in_progress'] }, 1, 0] } },
        completed: { $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] } },
        cancelled: { $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, 1, 0] } },
        totalEarnings: { $sum: { $cond: [{ $eq: ['$status', 'completed'] }, '$price', 0] } },
      },
    },
  ]);
  
  return stats[0] || {
    total: 0,
    pending: 0,
    accepted: 0,
    onTheWay: 0,
    inProgress: 0,
    completed: 0,
    cancelled: 0,
    totalEarnings: 0,
  };
};
<<<<<<< HEAD

export interface AdminBookingListQuery {
  status?: BookingStatus;
  paymentStatus?: import('../models/Booking').PaymentStatus;
  technicianId?: string;
  userId?: string;
  from?: Date;
  to?: Date;
  search?: string;
  page?: number;
  limit?: number;
  sort?: 'createdAt' | 'scheduledDate' | 'price';
  order?: 'asc' | 'desc';
}

export const listBookingsForAdmin = async (
  q: AdminBookingListQuery
): Promise<{ bookings: IBooking[]; total: number; page: number; pages: number }> => {
  const page = Math.max(1, q.page ?? 1);
  const limit = Math.min(100, Math.max(1, q.limit ?? 20));
  const filter: Record<string, unknown> = {};

  if (q.status) filter.status = q.status;
  if (q.paymentStatus) filter.paymentStatus = q.paymentStatus;
  if (q.technicianId) filter.technician = new mongoose.Types.ObjectId(q.technicianId);
  if (q.userId) filter.user = new mongoose.Types.ObjectId(q.userId);
  if (q.from || q.to) {
    filter.createdAt = {} as Record<string, Date>;
    if (q.from) (filter.createdAt as any).$gte = q.from;
    if (q.to) (filter.createdAt as any).$lte = q.to;
  }
  if (q.search?.trim()) {
    const rx = new RegExp(q.search.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
    filter.$or = [{ address: rx }, { description: rx }];
  }

  const sortField = q.sort === 'scheduledDate' ? 'scheduledDate' : q.sort === 'price' ? 'price' : 'createdAt';
  const sortDir = q.order === 'asc' ? 1 : -1;
  const skip = (page - 1) * limit;

  const [bookings, total] = await Promise.all([
    Booking.find(filter)
      .populate([
        { path: 'user', select: 'firstName lastName phone email' },
        { path: 'technician', populate: { path: 'user', select: 'firstName lastName phone' } },
        { path: 'service', select: 'name' },
      ])
      .sort({ [sortField]: sortDir })
      .skip(skip)
      .limit(limit),
    Booking.countDocuments(filter),
  ]);

  return { bookings, total, page, pages: Math.ceil(total / limit) || 1 };
};

export const updateBookingInternalNotes = async (bookingId: string, notes: string): Promise<IBooking> => {
  const booking = await Booking.findByIdAndUpdate(bookingId, { notes }, { new: true }).populate([
    { path: 'user', select: '-password' },
    { path: 'technician', populate: { path: 'user', select: '-password' } },
    { path: 'service' },
  ]);
  if (!booking) throw createError('Booking not found', 404);
  return booking;
};

export const assignBookingTechnician = async (
  bookingId: string,
  newTechnicianProfileId: string
): Promise<IBooking> => {
  const booking = await Booking.findById(bookingId);
  if (!booking) throw createError('Booking not found', 404);
  if (booking.status === 'completed' || booking.status === 'cancelled') {
    throw createError('Cannot reassign technician for this booking status', 400);
  }
  const technician = await Technician.findById(newTechnicianProfileId);
  if (!technician) throw createError('Technician not found', 404);
  if (!technician.isApproved) throw createError('Technician is not approved', 400);
  if (technician.isSuspended) {
    throw createError('Technician is suspended', 400);
  }
  booking.technician = technician._id as mongoose.Types.ObjectId;
  await booking.save();
  return booking.populate([
    { path: 'user', select: '-password' },
    { path: 'technician', populate: { path: 'user', select: '-password' } },
    { path: 'service' },
  ]);
};
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
