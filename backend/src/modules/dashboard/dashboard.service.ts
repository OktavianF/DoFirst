import { TaskRepository } from '../tasks/task.repository';
import { TaskService } from '../tasks/task.service';
import { prisma } from '../../lib/prisma';

const taskRepository = new TaskRepository();
const taskService = new TaskService();

function formatDateKey(date: Date) {
  return date.toISOString().slice(0, 10);
}

export class DashboardService {
  async getDashboard(userId: string) {
    const profile = await prisma.profile.findUnique({
      where: { id: userId },
    });

    const totalTasks = await taskRepository.countByUser(userId);
    const completedTasks = await prisma.task.count({
      where: { userId, isCompleted: true },
    });
    const highPriorityTasks = await taskRepository.countHighPriorityIncompleteByUser(userId);

    const activeTasks = await taskRepository.findActiveByUser(userId);
    const recalculatedActive = activeTasks
      .map((t) => taskService.recalculateTask(t))
      .sort((a, b) => b.score - a.score);

    const heroTask = recalculatedActive.length > 0 ? recalculatedActive[0] : null;
    const upcomingTasks = recalculatedActive.slice(1, 4);

    const sinceDate = new Date();
    sinceDate.setDate(sinceDate.getDate() - 6);
    sinceDate.setHours(0, 0, 0, 0);

    const recentCompletedTasks = await prisma.task.findMany({
      where: {
        userId,
        isCompleted: true,
        completedAt: { gte: sinceDate },
      },
      orderBy: { completedAt: 'desc' },
    });

    const completedTasksAll = await taskRepository.findCompletedByUser(userId);
    const completedFocusValues = completedTasksAll
      .map((task) => task.focusDuration)
      .filter((value): value is number => value !== null && value !== undefined);

    const averageFocus = completedFocusValues.length
      ? completedFocusValues.reduce((sum, value) => sum + value, 0) / completedFocusValues.length
      : 0;

    const tasksPerWeekMap = recentCompletedTasks.reduce<Record<string, number>>((acc, task) => {
      if (!task.completedAt) return acc;
      const dateKey = formatDateKey(task.completedAt);
      acc[dateKey] = (acc[dateKey] || 0) + 1;
      return acc;
    }, {});

    const tasksPerWeek = Object.entries(tasksPerWeekMap)
      .map(([date, count]) => ({ date, count }))
      .sort((a, b) => a.date.localeCompare(b.date));

    return {
      summary: {
        totalTasks,
        completedTasks,
        highPriorityTasks,
      },
      stats: {
        tasksPerWeek,
        averageFocus,
      },
      history: completedTasksAll,
      userName: profile?.fullName || 'User',
      heroTask: heroTask
        ? {
            id: heroTask.id,
            title: heroTask.title,
            score: heroTask.score,
            priority: heroTask.priority,
            deadline: heroTask.deadline,
            tags: heroTask.tags,
          }
        : null,
      upcomingTasks: upcomingTasks.map((t) => ({
        id: t.id,
        title: t.title,
        score: t.score,
        priority: t.priority,
        deadline: t.deadline,
      })),
    };
  }
}
