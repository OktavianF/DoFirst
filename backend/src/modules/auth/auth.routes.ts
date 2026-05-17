import { Router } from 'express';
import { AuthController } from './auth.controller';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new AuthController();

router.post('/signup', controller.signup);
router.post('/login', controller.login);
router.post('/google', controller.googleSignIn);
router.get('/me', authMiddleware, controller.me);
router.post('/refresh', controller.refresh);
router.post('/forgot-password', controller.forgotPassword);
router.post('/reset-password', controller.resetPassword);

export { router as authRoutes };
