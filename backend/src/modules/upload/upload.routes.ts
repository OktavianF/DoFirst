import { Router } from 'express';
import multer from 'multer';
import { UploadController } from './upload.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new UploadController();

// Configure multer for memory storage (buffer)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
});

router.use(authMiddleware);

router.post('/task-attachment/:taskId', upload.single('file'), controller.uploadTaskAttachment);
router.post('/avatar', upload.single('file'), controller.uploadAvatar);

export { router as uploadRoutes };
