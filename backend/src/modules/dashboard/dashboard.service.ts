import { TaskRepository } from '../tasks/task.repository';
import { TaskService } from '../tasks/task.service';
import { prisma } from '../../lib/prisma';

const taskRepository = new TaskRepository();
const taskService = new TaskService();

export class DashboardService {
  /**
   * Get aggregated dashboard data for the home page:
   * - User's name
   * - Total active tasks count
   * - Completed tasks count (from history)
   * - High priority count
   * - Hero task (highest scored task — dynamically recalculated)
   * - Upcoming tasks (next 3 after hero — dynamically recalculated)
   * - Average focus minutes (from focus_sessions)
   * - Recent history (4 latest completed tasks)
   */
  async getDashboard(userId: string) {
    const [profile, totalTasks, completedCount, focusSessions, recentHistory] = await Promise.all([
      prisma.profile.findUnique({ where: { id: userId } }),
      taskRepository.countByUser(userId),
      prisma.completedTask.count({ where: { userId } }),
      prisma.focusSession.findMany({
        where: { userId, sessionType: 'focus' },
      }),
      prisma.completedTask.findMany({
        where: { userId },
        orderBy: { completedAt: 'desc' },
        take: 4,
      }),
    ]);

    // Fetch all active tasks and recalculate scores dynamically
    const allTasks = await taskRepository.findAllByUser(userId);
    const recalculated = allTasks
      .map((t) => taskService.recalculateTask(t))
      .sort((a, b) => b.score - a.score);

    const heroTask = recalculated.length > 0 ? recalculated[0] : null;
    const upcomingTasks = recalculated.slice(1, 4); // Next 3 after hero

    // Calculate high priority count
    const highPriorityCount = recalculated.filter((t) => t.priority === 'HIGH').length;

    // Calculate average focus minutes
    const totalFocusMinutes = focusSessions.reduce((sum, s) => sum + s.durationMinutes, 0);
    const avgFocusMinutes = focusSessions.length > 0
      ? Math.round(totalFocusMinutes / focusSessions.length)
      : 0;

    // Unread notifications count
    const unreadNotifications = await prisma.notification.count({
      where: { userId, isRead: false },
    });

    return {
      userName: profile?.fullName || 'User',
      totalTasks,
      completedTasksCount: completedCount,
      highPriorityCount,
      averageFocusMinutes: avgFocusMinutes,
      totalFocusMinutes,
      unreadNotifications,
      heroTask: heroTask
        ? {
            id: heroTask.id,
            title: heroTask.title,
            description: heroTask.description,
            score: heroTask.score,
            priority: heroTask.priority,
            deadline: heroTask.deadline,
            tags: heroTask.tags,
            importance: heroTask.importance,
            difficulty: heroTask.difficulty,
            urgency: heroTask.urgency,
          }
        : null,
      upcomingTasks: upcomingTasks.map((t) => ({
        id: t.id,
        title: t.title,
        score: t.score,
        priority: t.priority,
        deadline: t.deadline,
      })),
      recentHistory: recentHistory.map((t) => ({
        id: t.id,
        title: t.title,
        score: t.score,
        priority: t.priority,
        completedAt: t.completedAt,
        focusDuration: t.focusDuration,
      })),
    };
  }
}
