import { Router } from 'express';
import {
  getMyTechnicianProfile,
  createProfile,
  updateProfile,
  addService,
  removeService,
  setAvailability,
  listTechnicians,
  getTechnician,
  approveTechnicianProfile,
  listPendingTechnicians,
<<<<<<< HEAD
  setTechnicianSuspended,
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
} from '../controllers/technician.controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

<<<<<<< HEAD
// Static paths must be registered before `/:id` to avoid shadowing
router.get('/profile/me', authenticate, authorize('technician'), getMyTechnicianProfile);
router.get('/pending', authenticate, authorize('admin'), listPendingTechnicians);
router.put('/:id/suspend', authenticate, authorize('admin'), setTechnicianSuspended);

// Public routes
router.get('/', listTechnicians);
router.get('/:id', getTechnician);

// Protected routes (technician only)
=======
// Public routes
router.get('/', listTechnicians);
router.get('/pending', listPendingTechnicians);
router.get('/:id', getTechnician);

// Protected routes (technician only)
router.get('/profile/me', authenticate, authorize('technician'), getMyTechnicianProfile);
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
router.post('/profile', authenticate, createProfile);
router.put('/:id', authenticate, authorize('technician', 'admin'), updateProfile);
router.post('/:id/services', authenticate, authorize('technician'), addService);
router.delete('/:id/services/:serviceId', authenticate, authorize('technician'), removeService);
router.put('/:id/availability', authenticate, authorize('technician'), setAvailability);

// Admin routes
router.put('/:id/approve', authenticate, authorize('admin'), approveTechnicianProfile);

export default router;
