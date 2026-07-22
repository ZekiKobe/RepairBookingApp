import { Router } from 'express';
import {
  submitReview,
  getTechnicianReviewList,
  getMyReviews,
  getReview,
  updateMyReview,
  deleteMyReview,
} from '../controllers/review.controller';
import { authenticate } from '../middleware/auth';

const router = Router();

// Public routes
router.get('/technician/:technicianId', getTechnicianReviewList);

// Protected static paths before `/:id`
router.post('/', authenticate, submitReview);
router.get('/my/reviews', authenticate, getMyReviews);
router.get('/:id', getReview);

router.put('/:id', authenticate, updateMyReview);
router.delete('/:id', authenticate, deleteMyReview);

export default router;
