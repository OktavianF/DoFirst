import { prisma } from '../../lib/prisma';

export class SettingsService {
  /**
   * Get user settings. Creates default settings if not exists.
   */
  async getSettings(userId: string) {
    let settings = await prisma.userSettings.findUnique({
      where: { userId },
    });

    if (!settings) {
      settings = await prisma.userSettings.create({
        data: { userId },
      });
    }

    return settings;
  }

  /**
   * Update user settings (focus/break durations, preferences, FCM token).
   */
  async updateSettings(userId: string, data: {
    focusDuration?: number;
    shortBreak?: number;
    longBreak?: number;
    sessionsBeforeLongBreak?: number;
    vibration?: boolean;
    autoStartNextSession?: boolean;
    autoStartBreak?: boolean;
    sound?: string;
    fcmToken?: string | null;
  }) {
    // Ensure settings record exists (upsert)
    return prisma.userSettings.upsert({
      where: { userId },
      create: {
        userId,
        ...data,
        updatedAt: new Date(),
      },
      update: {
        ...data,
        updatedAt: new Date(),
      },
    });
  }
}
