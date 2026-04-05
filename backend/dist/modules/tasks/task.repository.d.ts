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
export declare class TaskRepository {
    create(data: CreateTaskData & {
        score: number;
        priority: string;
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
    findAllByUser(userId: string): Promise<{
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
    findById(id: string, userId: string): Promise<{
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
    } | null>;
    delete(id: string, userId: string): Promise<import(".prisma/client").Prisma.BatchPayload>;
    countByUser(userId: string): Promise<number>;
    getTopTask(userId: string): Promise<{
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
    } | null>;
    getUpcomingTasks(userId: string, limit?: number): Promise<{
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
}
export {};
//# sourceMappingURL=task.repository.d.ts.map