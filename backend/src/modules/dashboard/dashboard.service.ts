import { TaskRepository } from '../tasks/task.repository';
import { TaskService } from '../tasks/task.service';
import { prisma } from '../../lib/prisma';

const taskRepository = new TaskRepository();
const taskService = new TaskService();

export class DashboardService {
  /**
   * Get aggregated dashboard data for the home page:
   * - User's name
   * - Total tasks count
   * - Hero task (highest scored task — dynamically recalculated)
   * - Upcoming tasks (next 3 after hero — dynamically recalculated)
   */
  async getDashboard(userId: string) {
    const profile = await prisma.profile.findUnique({
      where: { id: userId },
    });

    const totalTasks = await taskRepository.countByUser(userId);

    // Fetch all tasks and recalculate scores dynamically
    const allTasks = await taskRepository.findAllByUser(userId);
    const recalculated = allTasks
      .map((t) => taskService.recalculateTask(t))
      .sort((a, b) => b.score - a.score);

    const heroTask = recalculated.length > 0 ? recalculated[0] : null;
    const upcomingTasks = recalculated.slice(1, 4); // Next 3 after hero

    return {
      userName: profile?.fullName || 'User',
      totalTasks,
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
