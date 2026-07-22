import { Router } from 'express';
import {
  postEstimate,
  getMyEstimates,
  getTechnicianEstimates,
  putRespondEstimate,
} from '../controllers/estimate.controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

router.use(authenticate);

router.post('/', authorize('user'), postEstimate);
router.get('/mine', getMyEstimates);
router.get('/technician/incoming', authorize('technician'), getTechnicianEstimates);
router.put('/:id/respond', authorize('technician'), putRespondEstimate);

export default router;
