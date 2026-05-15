import { Router, Request, Response, NextFunction } from 'express';
import { NotificationController } from './notification.controller';
import { PushNotificationService } from './push.service';
import { authMiddleware } from '../../middleware/auth';

const router = Router();
const controller = new NotificationController();
const pushService = new PushNotificationService();

router.use(authMiddleware);

router.get('/', controller.list);
router.get('/unread-count', controller.unreadCount);
router.put('/read-all', controller.markAllRead);
router.put('/:id/read', controller.markRead);

// FCM token registration — called from Flutter on app startup
router.post('/register-token', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { user } = req as any;
    const { fcmToken } = req.body;

    if (!fcmToken) {
      res.status(400).json({ success: false, error: 'FCM token is required' });
      return;
    }

    const { prisma } = await import('../../lib/prisma');
    await prisma.userSettings.upsert({
      where: { userId: user.id },
      create: { userId: user.id, fcmToken },
      update: { fcmToken },
    });

    res.json({ success: true, data: { message: 'Token registered' } });
  } catch (err) {
    next(err);
  }
});

// Cron endpoint — can be called by Edge Function or external cron
router.post('/check-deadlines', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await pushService.checkDeadlines();
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
});

export { router as notificationRoutes };
