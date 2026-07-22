import { Router } from 'express';
import multer from 'multer';
import { authenticate } from '../middleware/auth';
import { uploadLimiter } from '../middleware/rateLimit';
import { uploadAvatar, uploadAttachment } from '../controllers/upload.controller';

const router = Router();

// Use memory storage — buffer is passed directly to storage provider
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (_req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'application/pdf'];
    cb(null, allowed.includes(file.mimetype));
  },
});

router.use(authenticate);
router.use(uploadLimiter);

router.post('/avatar', upload.single('avatar'), uploadAvatar);
router.post('/attachment', upload.single('file'), uploadAttachment);

export default router;
