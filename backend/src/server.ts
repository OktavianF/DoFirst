import { app } from './app';
import { env } from './config/env';
import { PushNotificationService } from './modules/notifications/push.service';

const pushService = new PushNotificationService();

const PORT = env.PORT;

app.listen(PORT, () => {
  console.log(`🚀 DoFirst API running on http://localhost:${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🌍 Environment: ${env.NODE_ENV}`);

  // Auto-check deadlines every 1 minute
  // Hanya jalankan internal cron jika di environment development
  if (env.NODE_ENV === 'development') {
    setInterval(async () => {
      try {
        await pushService.checkDeadlines();
      } catch (err) {
        console.error('Failed to run deadline cron:', err);
      }
    }, 1000 * 60);
  }
});
