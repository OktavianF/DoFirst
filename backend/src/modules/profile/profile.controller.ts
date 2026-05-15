import { Request, Response, NextFunction } from 'express';
import { ProfileService } from './profile.service';
import { AuthenticatedRequest } from '../../middleware/auth';

const profileService = new ProfileService();

export class ProfileController {
  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const profile = await profileService.updateProfile(user.id, req.body);

      res.json({
        success: true,
        data: profile,
      });
    } catch (err) {
      next(err);
    }
  }
}
