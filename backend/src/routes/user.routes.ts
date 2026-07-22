import { Router } from 'express';
<<<<<<< HEAD
import { getProfile, updateProfile, setLocation, getAllUsers, getUser, updateFcmToken, exportMyData, deleteMyAccount, recordConsents } from '../controllers/user.controller';
=======
import { getProfile, updateProfile, setLocation, getAllUsers, getUser, updateFcmToken } from '../controllers/user.controller';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

// User routes
router.get('/profile', authenticate, getProfile);
router.put('/profile', authenticate, updateProfile);
router.put('/location', authenticate, setLocation);
router.put('/fcm-token', authenticate, updateFcmToken);

<<<<<<< HEAD
router.get('/me/data-export', authenticate, exportMyData);
router.delete('/me', authenticate, deleteMyAccount);
router.post('/me/consents', authenticate, recordConsents);

=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
// Admin routes
router.get('/', authenticate, authorize('admin'), getAllUsers);
router.get('/:id', authenticate, authorize('admin'), getUser);

export default router;
