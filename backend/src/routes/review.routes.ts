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
<<<<<<< HEAD

// Protected static paths before `/:id`
router.post('/', authenticate, submitReview);
router.get('/my/reviews', authenticate, getMyReviews);
router.get('/:id', getReview);

=======
router.get('/:id', getReview);

// Protected routes
router.post('/', authenticate, submitReview);
router.get('/my/reviews', authenticate, getMyReviews);
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
router.put('/:id', authenticate, updateMyReview);
router.delete('/:id', authenticate, deleteMyReview);

export default router;
