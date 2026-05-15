import { TaskRepository } from './task.repository';
import { AppError } from '../../lib/AppError';

const taskRepository = new TaskRepository();

export class TaskService {
  /**
   * Calculate deadline score based on how soon the deadline is.
   * Granular hour-based scale (0–10) so imminent deadlines dominate.
   *
   * | Condition            | Score |
   * |----------------------|-------|
   * | Overdue              | 10    |
   * | ≤ 30 min             | 9.5   |
   * | 30 min – 1 hour      | 9     |
   * | 1–3 hours            | 8     |
   * | 3–6 hours            | 7     |
   * | 6–12 hours           | 6     |
   * | 12–24 hours (today)  | 5     |
   * | 1–2 days (tomorrow)  | 4     |
   * | 2–4 days             | 3     |
   * | 4–7 days             | 2     |
   * | 7+ days              | 1     |
   * | No deadline          | 0     |
   */
  calculateDeadlineScore(deadline?: Date | null): number {
    if (!deadline) return 0;

    const now = new Date();
    const diffMs = deadline.getTime() - now.getTime();

    // Overdue
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
    return 1; // 7+ days
  }

  /**
   * Calculate priority score using Deadline-Dominant Weighted Scoring Model.
   *
   * All parameters normalized to 0–10 scale, then weighted:
   *   Final Score = (0.10 × I_norm) + (0.15 × U_norm) + (0.10 × D_norm) + (0.65 × DL)
   *
   * Deadline weight = 65%, ensuring imminent deadlines always rank highest.
   */
  calculateScore(importance: number, urgency: number, difficulty: number, deadlineScore: number): number {
    // Normalize I, U, D from 1–5 to 0–10
    const iNorm = (importance - 1) * 2.5;
    const uNorm = (urgency - 1) * 2.5;
    const dNorm = (difficulty - 1) * 2.5;

    const score = (0.10 * iNorm) + (0.15 * uNorm) + (0.10 * dNorm) + (0.65 * deadlineScore);
    const rounded = Math.round(score * 10) / 10; // Round to 1 decimal
    return Math.min(10, Math.max(0, rounded));
  }

  /**
   * Derive priority label from score.
   * 0–3.3 → LOW, 3.4–6.6 → MEDIUM, 6.7–10 → HIGH
   */
  derivePriority(score: number): string {
    if (score >= 6.7) return 'HIGH';
    if (score >= 3.4) return 'MEDIUM';
    return 'LOW';
  }

  /**
   * Recalculate score and priority for a task based on current time.
   * Deadline proximity changes daily, so scores must be dynamic.
   */
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

  /**
   * Parse deadline string from frontend into a Date.
   * Primarily expects ISO 8601 strings with timezone info.
   * Also handles legacy: "Today", "Tomorrow", "Next Week" as fallback.
   */
  private parseDeadline(deadline?: string): Date | undefined {
    if (!deadline) return undefined;

    const lower = deadline.toLowerCase().trim();

    // Legacy fallback for "Today", "Tomorrow", "Next Week"
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
        // Parse ISO 8601 string (preserves timezone info from client)
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
    });
  }

  /**
   * Update an existing task. Recalculates score after update.
   */
  async updateTask(
    userId: string,
    taskId: string,
    data: {
      title?: string;
      description?: string | null;
      importance?: number;
      difficulty?: number;
      urgency?: number;
      deadline?: string | null;
      tags?: string[];
      fileUrl?: string | null;
    }
  ) {
    const existing = await taskRepository.findById(taskId, userId);
    if (!existing) {
      throw AppError.notFound('Task not found');
    }

    const importance = data.importance !== undefined
      ? Math.min(5, Math.max(1, data.importance))
      : existing.importance;
    const difficulty = data.difficulty !== undefined
      ? Math.min(5, Math.max(1, data.difficulty))
      : existing.difficulty;
    const urgency = data.urgency !== undefined
      ? Math.min(5, Math.max(1, data.urgency))
      : existing.urgency;

    let deadline: Date | null | undefined = undefined;
    if (data.deadline === null) {
      deadline = null;
    } else if (data.deadline !== undefined) {
      deadline = this.parseDeadline(data.deadline) ?? null;
    } else {
      deadline = existing.deadline;
    }

    const deadlineScore = this.calculateDeadlineScore(deadline);
    const score = this.calculateScore(importance, urgency, difficulty, deadlineScore);
    const priority = this.derivePriority(score);

    const updateData: Record<string, unknown> = {
      importance,
      difficulty,
      urgency,
      score,
      priority,
      deadline,
    };

    if (data.title !== undefined) updateData.title = data.title.trim();
    if (data.description !== undefined) updateData.description = data.description?.trim() || null;
    if (data.tags !== undefined) updateData.tags = data.tags;
    if (data.fileUrl !== undefined) updateData.fileUrl = data.fileUrl;

    return taskRepository.updateAndReturn(taskId, userId, updateData);
  }

  /**
   * Delete a task permanently (without archiving).
   */
  async deleteTask(userId: string, taskId: string) {
    const task = await taskRepository.findById(taskId, userId);
    if (!task) {
      throw AppError.notFound('Task not found');
    }

    await taskRepository.delete(taskId, userId);
    return { message: 'Task deleted successfully' };
  }

  /**
   * Get all tasks for a user, with scores recalculated dynamically
   * based on current deadline proximity.
   */
  async getTasksByUser(userId: string) {
    const tasks = await taskRepository.findAllByUser(userId);
    // Recalculate scores dynamically — deadline proximity changes daily
    const recalculated = tasks.map((t) => this.recalculateTask(t));
    // Sort by recalculated score descending
    recalculated.sort((a, b) => b.score - a.score);
    return recalculated;
  }

  async getTaskById(userId: string, taskId: string) {
    const task = await taskRepository.findById(taskId, userId);
    if (!task) {
      throw AppError.notFound('Task not found');
    }
    return this.recalculateTask(task);
  }

  /**
   * Complete a task: archives it to completed_tasks, then deletes from active tasks.
   * The heroTask on the dashboard will automatically shift to the next highest-scored task.
   */
  async completeTask(userId: string, taskId: string) {
    const task = await taskRepository.findById(taskId, userId);
    if (!task) {
      throw AppError.notFound('Task not found');
    }

    // Archive to completed_tasks for history
    await taskRepository.archiveTask({
      userId: task.userId,
      title: task.title,
      description: task.description,
      importance: task.importance,
      difficulty: task.difficulty,
      urgency: task.urgency,
      score: task.score,
      priority: task.priority,
      tags: task.tags,
      focusDuration: task.focusDuration ?? 0,
      fileUrl: task.fileUrl,
    });

    // Delete from active tasks
    await taskRepository.delete(taskId, userId);

    return { message: 'Task completed and archived', task };
  }
}
