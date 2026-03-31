import { Router } from 'express';
import { TaskController } from './task.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new TaskController();

// All task routes require authentication
router.use(authMiddleware);

router.post('/', controller.create);
router.get('/', controller.list);
router.get('/:id', controller.getById);
router.delete('/:id/complete', controller.complete);

export { router as taskRoutes };
