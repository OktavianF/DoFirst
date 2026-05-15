import { Router } from 'express';
import { FocusController } from './focus.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new FocusController();

router.use(authMiddleware);

router.post('/sessions', controller.recordSession);
router.get('/stats', controller.getStats);

export { router as focusRoutes };
