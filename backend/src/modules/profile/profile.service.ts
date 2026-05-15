import { prisma } from '../../lib/prisma';
import { AppError } from '../../lib/AppError';

export class ProfileService {
  /**
   * Update user profile (fullName, avatarUrl).
   */
  async updateProfile(userId: string, data: { fullName?: string; avatarUrl?: string | null }) {
    const profile = await prisma.profile.findUnique({ where: { id: userId } });
    if (!profile) {
      throw AppError.notFound('Profile not found');
    }

    const updateData: Record<string, unknown> = {};
    if (data.fullName !== undefined) {
      if (!data.fullName || data.fullName.trim().length === 0) {
        throw AppError.badRequest('Full name cannot be empty');
      }
      updateData.fullName = data.fullName.trim();
    }
    if (data.avatarUrl !== undefined) {
      updateData.avatarUrl = data.avatarUrl;
    }

    return prisma.profile.update({
      where: { id: userId },
      data: updateData,
    });
  }
}
