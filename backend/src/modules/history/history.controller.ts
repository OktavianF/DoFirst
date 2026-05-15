import { Request, Response, NextFunction } from 'express';
import { HistoryService } from './history.service';
import { AuthenticatedRequest } from '../../middleware/auth';

const historyService = new HistoryService();

export class HistoryController {
  async list(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;

      const result = await historyService.getHistory(user.id, page, limit);

      res.json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }
}
