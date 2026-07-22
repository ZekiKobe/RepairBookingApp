import { Router } from 'express';
import {
  postDispute,
  getMyDisputes,
  getAdminDisputes,
  patchAdminDispute,
} from '../controllers/dispute.controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

router.use(authenticate);

router.post('/', postDispute);
router.get('/mine', getMyDisputes);

router.get('/admin/all', authorize('admin'), getAdminDisputes);
router.patch('/admin/:id', authorize('admin'), patchAdminDispute);

export default router;
