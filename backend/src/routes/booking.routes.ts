import { Router } from 'express';
import {
  createNewBooking,
  getMyBookings,
  getMyTechnicianBookings,
  getBooking,
<<<<<<< HEAD
  getBookingInvoice,
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  updateStatus,
  acceptBookingRequest,
  cancelBookingRequest,
  getMyStatistics,
  getAllBookings,
  getAdminStatistics,
<<<<<<< HEAD
  adminUpdateBookingNotes,
  adminAssignBookingTechnician,
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
} from '../controllers/booking.controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

// Protected routes
router.post('/', authenticate, authorize('user'), createNewBooking);
router.get('/my-bookings', authenticate, getMyBookings);
router.get('/technician-bookings', authenticate, authorize('technician'), getMyTechnicianBookings);
router.get('/statistics', authenticate, authorize('technician'), getMyStatistics);
<<<<<<< HEAD
router.get('/admin/all', authenticate, authorize('admin'), getAllBookings);
router.get('/admin/statistics', authenticate, authorize('admin'), getAdminStatistics);
router.put('/admin/:id/notes', authenticate, authorize('admin'), adminUpdateBookingNotes);
router.put('/admin/:id/technician', authenticate, authorize('admin'), adminAssignBookingTechnician);
router.get('/:id/invoice', authenticate, getBookingInvoice);
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
router.get('/:id', authenticate, getBooking);
router.put('/:id/status', authenticate, authorize('technician', 'admin'), updateStatus);
router.put('/:id/accept', authenticate, authorize('technician'), acceptBookingRequest);
router.put('/:id/cancel', authenticate, cancelBookingRequest);

<<<<<<< HEAD
=======
// Admin routes
router.get('/admin/all', authenticate, authorize('admin'), getAllBookings);
router.get('/admin/statistics', authenticate, authorize('admin'), getAdminStatistics);

>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
export default router;
