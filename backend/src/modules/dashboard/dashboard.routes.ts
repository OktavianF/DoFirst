import { Router } from 'express';
import { DashboardController } from './dashboard.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new DashboardController();

router.get('/', authMiddleware, controller.getDashboard);

export { router as dashboardRoutes };
