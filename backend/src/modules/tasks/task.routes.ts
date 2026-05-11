import { Router } from 'express';
import { TaskController } from './task.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new TaskController();

router.use(authMiddleware);

router.post('/', controller.create);
router.get('/notifications', controller.notifications);
router.get('/', controller.list);
router.get('/:id', controller.getById);


router.patch('/:id', controller.update);
router.delete('/:id', controller.delete);

router.delete('/:id/complete', controller.complete);

export { router as taskRoutes };