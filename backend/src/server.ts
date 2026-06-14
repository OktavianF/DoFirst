import { app } from './app';
import { env } from './config/env';
import { logger } from './lib/logger';
import { PushNotificationService } from './modules/notifications/push.service';

const pushService = new PushNotificationService();
const PORT = env.PORT;

app.listen(PORT, () => {
  logger.info(`🚀 DoFirst API running on http://localhost:${PORT}`);
  logger.info(`📋 Health check: http://localhost:${PORT}/api/health`);
  logger.debug(`🌍 Environment: ${env.NODE_ENV}`);

  // Jalankan internal cron untuk check deadline setiap 1 menit
  setInterval(async () => {
    try {
      await pushService.checkDeadlines();
    } catch (err) {
      logger.error('Failed to run deadline cron:', err);
    }
  }, 1000 * 60);
});
