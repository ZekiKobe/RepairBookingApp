import Review, { IReview } from '../models/Review';
import Booking from '../models/Booking';
import { updateTechnicianStats } from './technician.service';
import { createError } from '../middleware/errorHandler';

interface CreateReviewData {
  bookingId: string;
  userId: string;
  rating: number;
  comment?: string;
}

export const createReview = async (data: CreateReviewData): Promise<IReview> => {
  const { bookingId, userId, rating, comment } = data;
  
  // Find booking and verify it belongs to user and is completed
  const booking = await Booking.findOne({
    _id: bookingId,
    user: userId,
    status: 'completed',
  });
  
  if (!booking) {
    throw createError('Booking not found or not completed', 404);
  }
  
  // Check if review already exists
  const existingReview = await Review.findOne({ booking: bookingId });
  if (existingReview) {
    throw createError('Review already exists for this booking', 400);
  }
  
  // Create review
  const review = await Review.create({
    booking: bookingId,
    user: userId,
    technician: booking.technician,
    rating,
    comment,
  });
  
  // Update technician stats
  await updateTechnicianStats(booking.technician.toString(), rating);
  
  return review.populate([
    { path: 'user', select: 'firstName lastName avatar' },
    { path: 'technician', populate: { path: 'user', select: 'firstName lastName' } },
    { path: 'booking', select: 'service scheduledDate' },
  ]);
};

export const getReviewById = async (reviewId: string): Promise<IReview> => {
  const review = await Review.findById(reviewId).populate([
    { path: 'user', select: 'firstName lastName avatar' },
    { path: 'technician', populate: { path: 'user', select: 'firstName lastName avatar' } },
    { path: 'booking', select: 'service scheduledDate' },
  ]);
  
  if (!review) {
    throw createError('Review not found', 404);
  }
  
  return review;
};

export const getTechnicianReviews = async (
  technicianId: string,
  page: number = 1,
  limit: number = 20
): Promise<{ reviews: IReview[]; total: number; page: number; pages: number; averageRating: number }> => {
  const filter = { technician: technicianId, isVisible: true };
  
  const skip = (page - 1) * limit;
  
  const [reviews, total, avgResult] = await Promise.all([
    Review.find(filter)
      .populate([
        { path: 'user', select: 'firstName lastName avatar' },
        { path: 'booking', select: 'service scheduledDate' },
      ])
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    Review.countDocuments(filter),
    Review.aggregate([
      { $match: filter },
      { $group: { _id: null, avgRating: { $avg: '$rating' } } },
    ]),
  ]);
  
  const averageRating = avgResult[0]?.avgRating || 0;
  
  return {
    reviews,
    total,
    page,
    pages: Math.ceil(total / limit),
    averageRating: Math.round(averageRating * 10) / 10,
  };
};

export const getUserReviews = async (
  userId: string,
  page: number = 1,
  limit: number = 20
): Promise<{ reviews: IReview[]; total: number; page: number; pages: number }> => {
  const filter = { user: userId };
  
  const skip = (page - 1) * limit;
  
  const [reviews, total] = await Promise.all([
    Review.find(filter)
      .populate([
        { path: 'technician', populate: { path: 'user', select: 'firstName lastName avatar' } },
        { path: 'booking', select: 'service scheduledDate' },
      ])
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    Review.countDocuments(filter),
  ]);
  
  return {
    reviews,
    total,
    page,
    pages: Math.ceil(total / limit),
  };
};

export const updateReview = async (
  reviewId: string,
  userId: string,
  updateData: { rating?: number; comment?: string }
): Promise<IReview> => {
  const review = await Review.findOneAndUpdate(
    { _id: reviewId, user: userId },
    updateData,
    { new: true, runValidators: true }
  ).populate([
    { path: 'user', select: 'firstName lastName avatar' },
    { path: 'technician', populate: { path: 'user', select: 'firstName lastName' } },
    { path: 'booking', select: 'service scheduledDate' },
  ]);
  
  if (!review) {
    throw createError('Review not found or unauthorized', 404);
  }
  
  return review;
};

export const deleteReview = async (reviewId: string, userId: string): Promise<void> => {
  const review = await Review.findOneAndDelete({ _id: reviewId, user: userId });
  
  if (!review) {
    throw createError('Review not found or unauthorized', 404);
  }
};

export const hideReview = async (reviewId: string): Promise<IReview> => {
  const review = await Review.findByIdAndUpdate(
    reviewId,
    { isVisible: false },
    { new: true }
  );
  
  if (!review) {
    throw createError('Review not found', 404);
  }
  
  return review;
};
