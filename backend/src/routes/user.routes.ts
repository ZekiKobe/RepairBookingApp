import { Router } from 'express';
import { getProfile, updateProfile, setLocation, getAllUsers, getUser, updateFcmToken, exportMyData, deleteMyAccount, recordConsents } from '../controllers/user.controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

// User routes
router.get('/profile', authenticate, getProfile);
router.put('/profile', authenticate, updateProfile);
router.put('/location', authenticate, setLocation);
router.put('/fcm-token', authenticate, updateFcmToken);

router.get('/me/data-export', authenticate, exportMyData);
router.delete('/me', authenticate, deleteMyAccount);
router.post('/me/consents', authenticate, recordConsents);

// Admin routes
router.get('/', authenticate, authorize('admin'), getAllUsers);
router.get('/:id', authenticate, authorize('admin'), getUser);

export default router;
