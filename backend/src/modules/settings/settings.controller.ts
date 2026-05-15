import { Request, Response, NextFunction } from 'express';
import { SettingsService } from './settings.service';
import { AuthenticatedRequest } from '../../middleware/auth';

const settingsService = new SettingsService();

export class SettingsController {
  async get(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const settings = await settingsService.getSettings(user.id);

      res.json({
        success: true,
        data: settings,
      });
    } catch (err) {
      next(err);
    }
  }

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const settings = await settingsService.updateSettings(user.id, req.body);

      res.json({
        success: true,
        data: settings,
      });
    } catch (err) {
      next(err);
    }
  }
}
