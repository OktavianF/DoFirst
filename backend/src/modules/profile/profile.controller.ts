import { NextFunction, Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/auth';
import { ProfileService } from './profile.service';

const profileService = new ProfileService();

export class ProfileController {
  /**
   * GET /api/profile
   * Ambil data profile user yang sedang login
   */
  async getProfile(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user.id;

      const profile = await profileService.getProfile(userId);

      res.json({
        success: true,
        data: profile,
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * PUT /api/profile
   * Update data profile user yang sedang login
   * Body: { name?, email?, photo? }
   */
  async updateProfile(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user.id;
      const { name, email, photo } = req.body;

      const updated = await profileService.updateProfile(userId, { name, email, photo });

      res.json({
        success: true,
        data: updated,
        message: 'Profile updated successfully',
      });
    } catch (err) {
      next(err);
    }
  }
}
