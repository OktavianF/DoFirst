import { prisma } from '../../lib/prisma';
import { AppError } from '../../lib/AppError';

export class FocusService {
  /**
   * Record a completed focus or break session.
   */
  async recordSession(userId: string, data: {
    taskId?: string;
    durationMinutes: number;
    sessionType?: string;
    startedAt?: string;
    endedAt?: string;
  }) {
    if (!data.durationMinutes || data.durationMinutes <= 0) {
      throw AppError.badRequest('Duration must be positive');
    }

    const sessionType = data.sessionType || 'focus';
    if (!['focus', 'break'].includes(sessionType)) {
      throw AppError.badRequest('Session type must be "focus" or "break"');
    }

    // If recording a focus session with a task, update the task's focus_duration
    if (data.taskId && sessionType === 'focus') {
      const task = await prisma.task.findFirst({ where: { id: data.taskId, userId } });
      if (task) {
        await prisma.task.update({
          where: { id: data.taskId },
          data: {
            focusDuration: (task.focusDuration ?? 0) + data.durationMinutes,
          },
        });
      }
    }

    return prisma.focusSession.create({
      data: {
        userId,
        taskId: data.taskId || null,
        durationMinutes: data.durationMinutes,
        sessionType,
        startedAt: data.startedAt ? new Date(data.startedAt) : new Date(),
        endedAt: data.endedAt ? new Date(data.endedAt) : new Date(),
      },
    });
  }

  /**
   * Get aggregated focus stats for a user.
   */
  async getStats(userId: string) {
    const sessions = await prisma.focusSession.findMany({
      where: { userId, sessionType: 'focus' },
    });

    const totalMinutes = sessions.reduce((sum, s) => sum + s.durationMinutes, 0);
    const totalSessions = sessions.length;

    // Calculate sessions in the last 7 days
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    const recentSessions = sessions.filter(
      (s) => s.createdAt >= weekAgo
    );
    const recentMinutes = recentSessions.reduce((sum, s) => sum + s.durationMinutes, 0);

    // Average focus per day (last 7 days)
    const avgMinutesPerDay = Math.round(recentMinutes / 7);

    return {
      totalMinutes,
      totalSessions,
      recentMinutes,
      recentSessions: recentSessions.length,
      avgMinutesPerDay,
      totalHours: Math.round(totalMinutes / 60 * 10) / 10,
    };
  }
}
