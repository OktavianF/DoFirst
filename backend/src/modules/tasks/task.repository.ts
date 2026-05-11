import { prisma } from '../../lib/prisma';

interface CreateTaskData {
  userId: string;
  title: string;
  description?: string;
  importance: number;
  difficulty: number;
  urgency: number;
  deadline?: Date;
  tags?: string[];
  fileUrl?: string | null;
}

export class TaskRepository {
  async create(data: CreateTaskData & { score: number; priority: string }) {
    return prisma.task.create({
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
        fileUrl: data.fileUrl ?? null,
      },
    });
  }

  async update(id: string, userId: string, data: any) {
    return prisma.task.updateMany({
      where: { id, userId },
      data,
    });
  }

  async findAllByUser(userId: string) {
    return prisma.task.findMany({
      where: { userId },
      orderBy: { score: 'desc' },
    });
  }

  async findActiveByUser(userId: string) {
    return prisma.task.findMany({
      where: { userId, isCompleted: false },
      orderBy: { score: 'desc' },
    });
  }

  async findCompletedByUser(userId: string) {
    return prisma.task.findMany({
      where: { userId, isCompleted: true },
      orderBy: { completedAt: 'desc' },
    });
  }

  async findById(id: string, userId: string) {
    return prisma.task.findFirst({
      where: { id, userId },
    });
  }

  async completeTask(id: string, userId: string) {
    return prisma.task.updateMany({
      where: { id, userId },
      data: {
        isCompleted: true,
        completedAt: new Date(),
      },
    });
  }

  async delete(id: string, userId: string) {
    return prisma.task.deleteMany({
      where: { id, userId },
    });
  }

  async findUpcomingDeadlineTasks(userId: string) {
    const now = new Date();
    const nextHour = new Date(now.getTime() + 1000 * 60 * 60);

    return prisma.task.findMany({
      where: {
        userId,
        isCompleted: false,
        deadline: {
          gte: now,
          lte: nextHour,
        },
      },
      orderBy: { deadline: 'asc' },
    });
  }

  async findUpcomingDeadlineTasksToNotify(now: Date, nextHour: Date) {
    return prisma.task.findMany({
      where: {
        isCompleted: false,
        deadline: {
          gte: now,
          lte: nextHour,
        },
        lastNotifiedAt: null,
      },
      orderBy: { deadline: 'asc' },
    });
  }

  async markTaskNotified(taskId: string, userId: string) {
    return prisma.task.updateMany({
      where: { id: taskId, userId },
      data: { lastNotifiedAt: new Date() },
    });
  }

  async countByUser(userId: string) {
    return prisma.task.count({
      where: { userId },
    });
  }

  async countHighPriorityIncompleteByUser(userId: string) {
    return prisma.task.count({
      where: { userId, priority: 'HIGH', isCompleted: false },
    });
  }

  async getTopTask(userId: string) {
    return prisma.task.findFirst({
      where: { userId },
      orderBy: { score: 'desc' },
    });
  }

  async getUpcomingTasks(userId: string, limit: number = 3) {
    return prisma.task.findMany({
      where: { userId },
      orderBy: { score: 'desc' },
      skip: 1,
      take: limit,
    });
  }
}