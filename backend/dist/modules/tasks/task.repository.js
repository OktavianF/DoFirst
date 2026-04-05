"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TaskRepository = void 0;
const prisma_1 = require("../../lib/prisma");
class TaskRepository {
    async create(data) {
        return prisma_1.prisma.task.create({
            data: {
                userId: data.userId,
                title: data.title,
                description: data.description,
                importance: data.importance,
                difficulty: data.difficulty,
                urgency: data.urgency,
                score: data.score,
                priority: data.priority,
                deadline: data.deadline,
                tags: data.tags || [],
            },
        });
    }
    async findAllByUser(userId) {
        return prisma_1.prisma.task.findMany({
            where: { userId },
            orderBy: { score: 'desc' },
        });
    }
    async findById(id, userId) {
        return prisma_1.prisma.task.findFirst({
            where: { id, userId },
        });
    }
    async delete(id, userId) {
        return prisma_1.prisma.task.deleteMany({
            where: { id, userId },
        });
    }
    async countByUser(userId) {
        return prisma_1.prisma.task.count({
            where: { userId },
        });
    }
    async getTopTask(userId) {
        return prisma_1.prisma.task.findFirst({
            where: { userId },
            orderBy: { score: 'desc' },
        });
    }
    async getUpcomingTasks(userId, limit = 3) {
        return prisma_1.prisma.task.findMany({
            where: { userId },
            orderBy: { score: 'desc' },
            skip: 1, // Skip the hero task (highest score)
            take: limit,
        });
    }
}
exports.TaskRepository = TaskRepository;
//# sourceMappingURL=task.repository.js.map