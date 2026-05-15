import { Router } from 'express';
import { ProfileController } from './profile.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new ProfileController();

router.use(authMiddleware);

router.put('/', controller.update);

export { router as profileRoutes };
