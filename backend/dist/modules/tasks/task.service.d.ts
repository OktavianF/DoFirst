export declare class TaskService {
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
    calculateDeadlineScore(deadline?: Date | null): number;
    /**
     * Calculate priority score using Deadline-Dominant Weighted Scoring Model.
     *
     * All parameters normalized to 0–10 scale, then weighted:
     *   Final Score = (0.10 × I_norm) + (0.15 × U_norm) + (0.10 × D_norm) + (0.65 × DL)
     *
     * Deadline weight = 65%, ensuring imminent deadlines always rank highest.
     */
    calculateScore(importance: number, urgency: number, difficulty: number, deadlineScore: number): number;
    /**
     * Derive priority label from score.
     * 0–3.3 → LOW, 3.4–6.6 → MEDIUM, 6.7–10 → HIGH
     */
    derivePriority(score: number): string;
    /**
     * Recalculate score and priority for a task based on current time.
     * Deadline proximity changes daily, so scores must be dynamic.
     */
    recalculateTask<T extends {
        importance: number;
        urgency: number;
        difficulty: number;
        deadline: Date | null;
    }>(task: T): T & {
        score: number;
        priority: string;
    };
    /**
     * Parse deadline string from frontend into a Date.
     * Primarily expects ISO 8601 strings with timezone info.
     * Also handles legacy: "Today", "Tomorrow", "Next Week" as fallback.
     */
    private parseDeadline;
    createTask(userId: string, data: {
        title: string;
        description?: string;
        importance?: number;
        difficulty?: number;
        urgency?: number;
        deadline?: string;
        tags?: string[];
    }): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        title: string;
        description: string | null;
        importance: number;
        difficulty: number;
        urgency: number;
        score: number;
        priority: string;
        deadline: Date | null;
        isCompleted: boolean;
        completedAt: Date | null;
        focusDuration: number | null;
        tags: string[];
    }>;
    /**
     * Get all tasks for a user, with scores recalculated dynamically
     * based on current deadline proximity.
     */
    getTasksByUser(userId: string): Promise<({
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        title: string;
        description: string | null;
        importance: number;
        difficulty: number;
        urgency: number;
        score: number;
        priority: string;
        deadline: Date | null;
        isCompleted: boolean;
        completedAt: Date | null;
        focusDuration: number | null;
        tags: string[];
    } & {
        score: number;
        priority: string;
    })[]>;
    getTaskById(userId: string, taskId: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        title: string;
        description: string | null;
        importance: number;
        difficulty: number;
        urgency: number;
        score: number;
        priority: string;
        deadline: Date | null;
        isCompleted: boolean;
        completedAt: Date | null;
        focusDuration: number | null;
        tags: string[];
    } & {
        score: number;
        priority: string;
    }>;
    /**
     * Complete a task: deletes it from the database.
     * The heroTask on the dashboard will automatically shift to the next highest-scored task.
     */
    completeTask(userId: string, taskId: string): Promise<{
        message: string;
        task: {
            isCompleted: boolean;
            completedAt: Date;
            id: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string;
            title: string;
            description: string | null;
            importance: number;
            difficulty: number;
            urgency: number;
            score: number;
            priority: string;
            deadline: Date | null;
            focusDuration: number | null;
            tags: string[];
        };
    }>;
}
//# sourceMappingURL=task.service.d.ts.map