import { Router } from 'express';
import { ProfileController } from './profile.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new ProfileController();

// GET /api/profile - ambil data profile user yang login (dilindungi auth)
router.get('/', authMiddleware, (req, res, next) => controller.getProfile(req as any, res, next));

// PUT /api/profile - update data profile user yang login (dilindungi auth)
router.put('/', authMiddleware, (req, res, next) => controller.updateProfile(req as any, res, next));

export { router as profileRoutes };
