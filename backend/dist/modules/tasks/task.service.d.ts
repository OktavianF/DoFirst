export declare class TaskService {
    /**
     * Calculate priority score from task attributes.
     * Formula: ((importance * 0.4) + (urgency * 0.35) + (difficulty * 0.25)) * 2
     * Result is 0–10 scale.
     */
    private calculateScore;
    /**
     * Derive priority label from score.
     */
    private derivePriority;
    /**
     * Parse deadline string from frontend into a Date.
     * Handles: "Today", "Tomorrow", "Next Week", or date strings.
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
        tags: string[];
    }>;
    getTasksByUser(userId: string): Promise<{
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
        tags: string[];
    }[]>;
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
        tags: string[];
    }>;
    /**
     * Complete a task: deletes it from the database.
     * The heroTask on the dashboard will automatically shift to the next highest-scored task.
     */
    completeTask(userId: string, taskId: string): Promise<{
        message: string;
        task: {
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
            tags: string[];
        };
    }>;
}
//# sourceMappingURL=task.service.d.ts.map