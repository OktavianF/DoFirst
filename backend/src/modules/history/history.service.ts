import { prisma } from '../../lib/prisma';

export class HistoryService {
  /**
   * Get completed tasks (history) for a user, paginated.
   */
  async getHistory(userId: string, page: number = 1, limit: number = 20) {
    const offset = (page - 1) * limit;

    const [tasks, total] = await Promise.all([
      prisma.completedTask.findMany({
        where: { userId },
        orderBy: { completedAt: 'desc' },
        take: limit,
        skip: offset,
      }),
      prisma.completedTask.count({ where: { userId } }),
    ]);

    return {
      tasks,
      total,
      page,
      totalPages: Math.ceil(total / limit),
    };
  }
}
