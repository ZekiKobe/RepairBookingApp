import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import {
  createReview,
  getReviewById,
  getTechnicianReviews,
  getUserReviews,
  updateReview,
  deleteReview,
} from '../services/review.service';

export const submitReview = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { bookingId, rating, comment } = req.body;
    
    const review = await createReview({
      bookingId,
      userId: req.user!._id.toString(),
      rating,
      comment,
    });
    
    res.status(201).json({
      success: true,
      message: 'Review submitted successfully',
      data: { review },
    });
  } catch (error) {
    next(error);
  }
};

export const getTechnicianReviewList = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { technicianId } = req.params;
    const { page, limit } = req.query;
    
    const result = await getTechnicianReviews(
      technicianId as string,
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

export const getMyReviews = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { page, limit } = req.query;
    
    const result = await getUserReviews(
      req.user!._id.toString(),
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

export const getReview = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const review = await getReviewById(id as string);
    
    res.json({
      success: true,
      data: { review },
    });
  } catch (error) {
    next(error);
  }
};

export const updateMyReview = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const { rating, comment } = req.body;
    
    const review = await updateReview(id as string, req.user!._id.toString(), { rating, comment });
    
    res.json({
      success: true,
      message: 'Review updated successfully',
      data: { review },
    });
  } catch (error) {
    next(error);
  }
};

export const deleteMyReview = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    await deleteReview(id as string, req.user!._id.toString());
    
    res.json({
      success: true,
      message: 'Review deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};
