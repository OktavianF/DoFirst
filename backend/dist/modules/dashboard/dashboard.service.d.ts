export declare class DashboardService {
    getDashboard(userId: string): Promise<{
        summary: {
            totalTasks: number;
            completedTasks: number;
            highPriorityTasks: number;
        };
        stats: {
            tasksPerWeek: {
                date: string;
                count: number;
            }[];
            averageFocus: number;
        };
        history: {
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
        }[];
        userName: string;
        heroTask: {
            id: string;
            title: string;
            score: number;
            priority: string;
            deadline: Date | null;
            tags: string[];
        } | null;
        upcomingTasks: {
            id: string;
            title: string;
            score: number;
            priority: string;
            deadline: Date | null;
        }[];
    }>;
}
//# sourceMappingURL=dashboard.service.d.ts.map