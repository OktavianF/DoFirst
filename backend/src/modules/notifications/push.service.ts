import { getFirebaseApp, admin } from '../../lib/firebase';
import { prisma } from '../../lib/prisma';
import { NotificationService } from '../notifications/notification.service';

const notificationService = new NotificationService();

export class PushNotificationService {
  /**
   * Send a push notification to a specific user via FCM.
   * Also creates an in-app notification record.
   */
  async sendToUser(userId: string, payload: {
    title: string;
    body: string;
    type?: string;
    taskId?: string;
  }) {
    // Create in-app notification record first
    await notificationService.createNotification({
      userId,
      title: payload.title,
      message: payload.body,
      type: payload.type || 'info',
      taskId: payload.taskId,
    });

    // Get user's FCM token from settings
    const settings = await prisma.userSettings.findUnique({
      where: { userId },
    });

    if (!settings?.fcmToken) {
      console.log(`No FCM token for user ${userId}, skipping push`);
      return;
    }

    try {
      const app = getFirebaseApp();
      const messaging = app.messaging();

      await messaging.send({
        token: settings.fcmToken,
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: {
          type: payload.type || 'info',
          taskId: payload.taskId || '',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'dofirst_notifications',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title: payload.title,
                body: payload.body,
              },
              sound: 'default',
              badge: 1,
            },
          },
        },
      });

      console.log(`✅ Push sent to user ${userId}`);
    } catch (err: unknown) {
      const error = err as { code?: string; message?: string };
      console.error(`Failed to send push to user ${userId}:`, error.message);

      // If token is invalid, clear it
      if (error.code === 'messaging/registration-token-not-registered' ||
          error.code === 'messaging/invalid-registration-token') {
        await prisma.userSettings.update({
          where: { userId },
          data: { fcmToken: null },
        });
        console.log(`Cleared invalid FCM token for user ${userId}`);
      }
    }
  }

  /**
   * Check all tasks with upcoming deadlines and send notifications.
   * Called by cron / Edge Function periodically.
   */
  async checkDeadlines() {
    const now = new Date();
    const oneHourFromNow = new Date(now.getTime() + 60 * 60 * 1000);
    const threeHoursFromNow = new Date(now.getTime() + 3 * 60 * 60 * 1000);

    // Find tasks with deadlines within the next 3 hours that haven't been notified
    const tasks = await prisma.task.findMany({
      where: {
        deadline: {
          gte: now,
          lte: threeHoursFromNow,
        },
        isCompleted: false,
        lastNotifiedAt: null, // Avoid duplicate spamming
        user: {
          settings: {
            taskReminders: true,
          },
        },
      },
      include: {
        user: true,
      },
    });

    for (const task of tasks) {
      if (!task.deadline) continue;

      const diffMs = task.deadline.getTime() - now.getTime();
      const diffMinutes = Math.round(diffMs / (1000 * 60));

      let body: string;
      if (diffMinutes <= 30) {
        body = `"${task.title}" is due in ${diffMinutes} minutes!`;
      } else if (diffMinutes <= 60) {
        body = `"${task.title}" is due in less than an hour!`;
      } else {
        const hours = Math.round(diffMinutes / 60);
        body = `"${task.title}" is due in ${hours} hours.`;
      }

      await this.sendToUser(task.userId, {
        title: '⏰ Deadline Approaching',
        body,
        type: 'deadline',
        taskId: task.id,
      });

      // Update lastNotifiedAt to mark as notified
      await prisma.task.update({
        where: { id: task.id },
        data: { lastNotifiedAt: now },
      });
    }

    return { checked: tasks.length, timestamp: now.toISOString() };
  }
}
