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
      },
    });
  }

  async findAllByUser(userId: string) {
    return prisma.task.findMany({
      where: { userId },
      orderBy: { score: 'desc' },
    });
  }

  async findById(id: string, userId: string) {
    return prisma.task.findFirst({
      where: { id, userId },
    });
  }

  async delete(id: string, userId: string) {
    return prisma.task.deleteMany({
      where: { id, userId },
    });
  }

  async countByUser(userId: string) {
    return prisma.task.count({
      where: { userId },
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
      skip: 1, // Skip the hero task (highest score)
      take: limit,
    });
  }
}
