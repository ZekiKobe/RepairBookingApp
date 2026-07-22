import { Router } from 'express';
import multer from 'multer';
import { authenticate } from '../middleware/auth';
<<<<<<< HEAD
import { uploadLimiter } from '../middleware/rateLimit';
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
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
<<<<<<< HEAD
router.use(uploadLimiter);
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

router.post('/avatar', upload.single('avatar'), uploadAvatar);
router.post('/attachment', upload.single('file'), uploadAttachment);

export default router;
