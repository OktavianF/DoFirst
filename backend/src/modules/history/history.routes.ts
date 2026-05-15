import { Router } from 'express';
import { HistoryController } from './history.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new HistoryController();

router.use(authMiddleware);

router.get('/', controller.list);

export { router as historyRoutes };
