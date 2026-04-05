export declare class DashboardService {
    /**
     * Get aggregated dashboard data for the home page:
     * - User's name
     * - Total tasks count
     * - Hero task (highest scored task)
     * - Upcoming tasks (next 3 after hero)
     */
    getDashboard(userId: string): Promise<{
        userName: string;
        totalTasks: number;
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