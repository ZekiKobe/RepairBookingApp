import { Router } from 'express';
import {
  listServices,
  listCategories,
  getService,
  getServiceBySlugEndpoint,
  createNewService,
  updateExistingService,
  deleteExistingService,
} from '../controllers/service.controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

// Public routes
router.get('/', listServices);
router.get('/categories', listCategories);
router.get('/slug/:slug', getServiceBySlugEndpoint);
router.get('/:id', getService);

// Admin routes
router.post('/', authenticate, authorize('admin'), createNewService);
router.put('/:id', authenticate, authorize('admin'), updateExistingService);
router.delete('/:id', authenticate, authorize('admin'), deleteExistingService);

export default router;
