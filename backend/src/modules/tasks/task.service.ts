import { TaskRepository } from './task.repository';
import { AppError } from '../../lib/AppError';

const taskRepository = new TaskRepository();

export class TaskService {

  calculateDeadlineScore(deadline?: Date | null): number {
    if (!deadline) return 0;

    const now = new Date();
    const diffMs = deadline.getTime() - now.getTime();

    if (diffMs <= 0) return 10;

    const diffMinutes = diffMs / (1000 * 60);
    const diffHours = diffMinutes / 60;
    const diffDays = diffHours / 24;

    if (diffMinutes <= 30) return 9.5;
    if (diffHours <= 1) return 9;
    if (diffHours <= 3) return 8;
    if (diffHours <= 6) return 7;
    if (diffHours <= 12) return 6;
    if (diffHours <= 24) return 5;
    if (diffDays <= 2) return 4;
    if (diffDays <= 4) return 3;
    if (diffDays <= 7) return 2;
    return 1;
  }

  calculateScore(importance: number, urgency: number, difficulty: number, deadlineScore: number): number {
    const iNorm = (importance - 1) * 2.5;
    const uNorm = (urgency - 1) * 2.5;
    const dNorm = (difficulty - 1) * 2.5;

    const score = (0.10 * iNorm) + (0.15 * uNorm) + (0.10 * dNorm) + (0.65 * deadlineScore);
    const rounded = Math.round(score * 10) / 10;
    return Math.min(10, Math.max(0, rounded));
  }

  derivePriority(score: number): string {
    if (score >= 6.7) return 'HIGH';
    if (score >= 3.4) return 'MEDIUM';
    return 'LOW';
  }

  recalculateTask<T extends {
    importance: number;
    urgency: number;
    difficulty: number;
    deadline: Date | null;
  }>(task: T): T & { score: number; priority: string } {
    const deadlineScore = this.calculateDeadlineScore(task.deadline);
    const score = this.calculateScore(task.importance, task.urgency, task.difficulty, deadlineScore);
    const priority = this.derivePriority(score);
    return { ...task, score, priority };
  }

  private parseDeadline(deadline?: string): Date | undefined {
    if (!deadline) return undefined;

    const lower = deadline.toLowerCase().trim();

    switch (lower) {
      case 'today': {
        const d = new Date();
        d.setHours(23, 59, 59, 999);
        return d;
      }
      case 'tomorrow': {
        const d = new Date();
        d.setDate(d.getDate() + 1);
        d.setHours(23, 59, 59, 999);
        return d;
      }
      case 'next week': {
        const d = new Date();
        d.setDate(d.getDate() + 7);
        d.setHours(23, 59, 59, 999);
        return d;
      }
      default: {
        const parsed = new Date(deadline);
        return isNaN(parsed.getTime()) ? undefined : parsed;
      }
    }
  }

  async createTask(userId: string, data: any) {
    if (!data.title || data.title.trim().length === 0) {
      throw AppError.badRequest('Task title is required');
    }

    const importance = Math.min(5, Math.max(1, data.importance ?? 3));
    const difficulty = Math.min(5, Math.max(1, data.difficulty ?? 3));
    const urgency = Math.min(5, Math.max(1, data.urgency ?? 3));

    const deadline = this.parseDeadline(data.deadline);
    const deadlineScore = this.calculateDeadlineScore(deadline);
    const score = this.calculateScore(importance, urgency, difficulty, deadlineScore);
    const priority = this.derivePriority(score);

    return taskRepository.create({
      userId,
      title: data.title.trim(),
      description: data.description?.trim(),
      importance,
      difficulty,
      urgency,
      score,
      priority,
      deadline,
      tags: data.tags,
      fileUrl: data.fileUrl ?? null,
    });
  }

  async getTasksByUser(userId: string) {
    const tasks = await taskRepository.findActiveByUser(userId);
    const recalculated = tasks.map((t) => this.recalculateTask(t));
    recalculated.sort((a, b) => b.score - a.score);
    return recalculated;
  }

  async getTaskById(userId: string, taskId: string) {
    const task = await taskRepository.findById(taskId, userId);
    if (!task) throw AppError.notFound('Task not found');
    return this.recalculateTask(task);
  }

  async getUpcomingDeadlineTasks(userId: string) {
    const tasks = await taskRepository.findUpcomingDeadlineTasks(userId);
    return tasks.map((task) => this.recalculateTask(task));
  }

  async completeTask(userId: string, taskId: string) {
    const task = await taskRepository.findById(taskId, userId);

    if (!task) {
      throw AppError.notFound('Task not found');
    }

    if (!task.title || task.title.trim() === '') {
      throw AppError.badRequest('Task tidak valid / kosong');
    }

    const result = await taskRepository.completeTask(taskId, userId);

    if (result.count === 0) {
      throw AppError.notFound('Task not found');
    }

    return {
      message: 'Task completed successfully',
      task: {
        ...task,
        isCompleted: true,
        completedAt: new Date(),
      },
    };
  }

  //  UPDATE
  async updateTask(userId: string, taskId: string, data: any) {
    const existingTask = await taskRepository.findById(taskId, userId);
    if (!existingTask) throw AppError.notFound('Task not found');

    const importance = Math.min(5, Math.max(1, data.importance ?? existingTask.importance));
    const difficulty = Math.min(5, Math.max(1, data.difficulty ?? existingTask.difficulty));
    const urgency = Math.min(5, Math.max(1, data.urgency ?? existingTask.urgency));

    const deadline = data.deadline
      ? this.parseDeadline(data.deadline)
      : existingTask.deadline;

    const deadlineScore = this.calculateDeadlineScore(deadline);
    const score = this.calculateScore(importance, urgency, difficulty, deadlineScore);
    const priority = this.derivePriority(score);

    return taskRepository.update(taskId, userId, {
      title: data.title?.trim(),
      description: data.description?.trim(),
      importance,
      difficulty,
      urgency,
      deadline,
      tags: data.tags,
      fileUrl: data.fileUrl ?? null,
      score,
      priority,
    });
  }

  //  DELETE
  async deleteTask(userId: string, taskId: string) {
    const existingTask = await taskRepository.findById(taskId, userId);
    if (!existingTask) throw AppError.notFound('Task not found');

    await taskRepository.delete(taskId, userId);

    return {
      message: 'Task deleted successfully',
    };
  }
}