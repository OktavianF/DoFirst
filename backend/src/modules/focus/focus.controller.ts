import { Request, Response, NextFunction } from 'express';
import { FocusService } from './focus.service';
import { AuthenticatedRequest } from '../../middleware/auth';

const focusService = new FocusService();

export class FocusController {
  async recordSession(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const session = await focusService.recordSession(user.id, req.body);

      res.status(201).json({
        success: true,
        data: session,
      });
    } catch (err) {
      next(err);
    }
  }

  async getStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const stats = await focusService.getStats(user.id);

      res.json({
        success: true,
        data: stats,
      });
    } catch (err) {
      next(err);
    }
  }
}
