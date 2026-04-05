"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DashboardService = void 0;
const task_repository_1 = require("../tasks/task.repository");
const prisma_1 = require("../../lib/prisma");
const taskRepository = new task_repository_1.TaskRepository();
class DashboardService {
    /**
     * Get aggregated dashboard data for the home page:
     * - User's name
     * - Total tasks count
     * - Hero task (highest scored task)
     * - Upcoming tasks (next 3 after hero)
     */
    async getDashboard(userId) {
        const profile = await prisma_1.prisma.profile.findUnique({
            where: { id: userId },
        });
        const totalTasks = await taskRepository.countByUser(userId);
        const heroTask = await taskRepository.getTopTask(userId);
        const upcomingTasks = await taskRepository.getUpcomingTasks(userId, 3);
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
exports.DashboardService = DashboardService;
//# sourceMappingURL=dashboard.service.js.map