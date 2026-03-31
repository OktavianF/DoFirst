import { Request, Response, NextFunction } from 'express';
import { DashboardService } from './dashboard.service';
import { AuthenticatedRequest } from '../../middleware/auth';

const dashboardService = new DashboardService();

export class DashboardController {
  async getDashboard(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const dashboard = await dashboardService.getDashboard(user.id);

      res.json({
        success: true,
        data: dashboard,
      });
    } catch (err) {
      next(err);
    }
  }
}
