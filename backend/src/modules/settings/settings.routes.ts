import { Router } from 'express';
import { SettingsController } from './settings.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new SettingsController();

router.use(authMiddleware);

router.get('/', controller.get);
router.put('/', controller.update);

export { router as settingsRoutes };
