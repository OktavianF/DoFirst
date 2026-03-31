import { TaskRepository } from './task.repository';
import { AppError } from '../../lib/AppError';

const taskRepository = new TaskRepository();

export class TaskService {
  /**
   * Calculate priority score from task attributes.
   * Formula: ((importance * 0.4) + (urgency * 0.35) + (difficulty * 0.25)) * 2
   * Result is 0–10 scale.
   */
  private calculateScore(importance: number, urgency: number, difficulty: number): number {
    const raw = importance * 0.4 + urgency * 0.35 + difficulty * 0.25;
    const score = Math.round(raw * 2 * 10) / 10; // Scale to 0-10, round to 1 decimal
    return Math.min(10, Math.max(0, score));
  }

  /**
   * Derive priority label from score.
   */
  private derivePriority(score: number): string {
    if (score >= 7) return 'HIGH';
    if (score >= 4) return 'MEDIUM';
    return 'LOW';
  }

  /**
   * Parse deadline string from frontend into a Date.
   * Handles: "Today", "Tomorrow", "Next Week", or date strings.
   */
  private parseDeadline(deadline?: string): Date | undefined {
    if (!deadline) return undefined;

    const now = new Date();

    switch (deadline.toLowerCase()) {
      case 'today': {
        const d = new Date(now);
        d.setHours(23, 59, 59, 999);
        return d;
      }
      case 'tomorrow': {
        const d = new Date(now);
        d.setDate(d.getDate() + 1);
        d.setHours(23, 59, 59, 999);
        return d;
      }
      case 'next week': {
        const d = new Date(now);
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

  async createTask(
    userId: string,
    data: {
      title: string;
      description?: string;
      importance?: number;
      difficulty?: number;
      urgency?: number;
      deadline?: string;
      tags?: string[];
    }
  ) {
    if (!data.title || data.title.trim().length === 0) {
      throw AppError.badRequest('Task title is required');
    }

    const importance = Math.min(5, Math.max(1, data.importance ?? 3));
    const difficulty = Math.min(5, Math.max(1, data.difficulty ?? 3));
    const urgency = Math.min(5, Math.max(1, data.urgency ?? 3));

    const score = this.calculateScore(importance, urgency, difficulty);
    const priority = this.derivePriority(score);
    const deadline = this.parseDeadline(data.deadline);

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
    });
  }

  async getTasksByUser(userId: string) {
    const tasks = await taskRepository.findAllByUser(userId);
    return tasks;
  }

  async getTaskById(userId: string, taskId: string) {
    const task = await taskRepository.findById(taskId, userId);
    if (!task) {
      throw AppError.notFound('Task not found');
    }
    return task;
  }

  /**
   * Complete a task: deletes it from the database.
   * The heroTask on the dashboard will automatically shift to the next highest-scored task.
   */
  async completeTask(userId: string, taskId: string) {
    const task = await taskRepository.findById(taskId, userId);
    if (!task) {
      throw AppError.notFound('Task not found');
    }

    await taskRepository.delete(taskId, userId);
    return { message: 'Task completed and removed', task };
  }
}
