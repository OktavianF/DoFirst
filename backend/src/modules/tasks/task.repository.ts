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

interface UpdateTaskData {
  title?: string;
  description?: string | null;
  importance?: number;
  difficulty?: number;
  urgency?: number;
  deadline?: Date | null;
  tags?: string[];
  score?: number;
  priority?: string;
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
      },
    });
  }

  async findAllByUser(userId: string) {
    return prisma.task.findMany({
      where: { userId, isCompleted: false },
      orderBy: { score: 'desc' },
    });
  }

  async findById(id: string, userId: string) {
    return prisma.task.findFirst({
      where: { id, userId },
    });
  }

  async update(id: string, userId: string, data: UpdateTaskData) {
    return prisma.task.updateMany({
      where: { id, userId },
      data,
    });
  }

  async updateAndReturn(id: string, userId: string, data: UpdateTaskData) {
    // updateMany doesn't return the record, so we update then fetch
    await prisma.task.updateMany({
      where: { id, userId },
      data,
    });
    return prisma.task.findFirst({ where: { id, userId } });
  }

  async delete(id: string, userId: string) {
    return prisma.task.deleteMany({
      where: { id, userId },
    });
  }

  async countByUser(userId: string) {
    return prisma.task.count({
      where: { userId, isCompleted: false },
    });
  }

  async getTopTask(userId: string) {
    return prisma.task.findFirst({
      where: { userId, isCompleted: false },
      orderBy: { score: 'desc' },
    });
  }

  async getUpcomingTasks(userId: string, limit: number = 3) {
    return prisma.task.findMany({
      where: { userId, isCompleted: false },
      orderBy: { score: 'desc' },
      skip: 1, // Skip the hero task (highest score)
      take: limit,
    });
  }

  // --- Completed Tasks (History) ---

  async archiveTask(data: {
    userId: string;
    title: string;
    description?: string | null;
    importance: number;
    difficulty: number;
    urgency: number;
    score: number;
    priority: string;
    tags: string[];
    focusDuration: number;
    fileUrl?: string | null;
  }) {
    return prisma.completedTask.create({ data });
  }

  async getCompletedTasks(userId: string, limit: number = 20, offset: number = 0) {
    return prisma.completedTask.findMany({
      where: { userId },
      orderBy: { completedAt: 'desc' },
      take: limit,
      skip: offset,
    });
  }

  async countCompletedByUser(userId: string) {
    return prisma.completedTask.count({
      where: { userId },
    });
  }
}
