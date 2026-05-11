import { prisma } from '../../lib/prisma';
import { supabaseAdmin } from '../../lib/supabase';
import { AppError } from '../../lib/AppError';

export class ProfileService {
  /**
   * Get profile data untuk user yang login
   * Menggabungkan data dari Prisma (Profile) dan Supabase (Auth)
   */
  async getProfile(userId: string) {
    const profile = await prisma.profile.findUnique({
      where: { id: userId },
    });

    if (!profile) {
      throw AppError.notFound('User profile not found');
    }

    // Get email dari Supabase
    const { data: { user: supabaseUser }, error } = await supabaseAdmin.auth.admin.getUserById(userId);

    if (error || !supabaseUser) {
      throw AppError.notFound('User not found in auth system');
    }

    return {
      id: profile.id,
      name: profile.fullName,
      email: supabaseUser.email || null,
      photo: profile.avatarUrl,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    };
  }

  /**
   * Update profile data untuk user yang login
   * Bisa update: name, email, photo
   * Hanya field yang dikirim saja yang akan di-update (jangan overwrite dengan null)
   */
  async updateProfile(userId: string, data: any) {
    // Validasi name jika dikirim
    if (data.name !== undefined) {
      if (!data.name || data.name.trim() === '') {
        throw AppError.badRequest('Name cannot be empty');
      }
    }

    // Validasi email jika dikirim
    if (data.email !== undefined) {
      if (!data.email || data.email.trim() === '') {
        throw AppError.badRequest('Email cannot be empty');
      }

      if (!this.isValidEmail(data.email)) {
        throw AppError.badRequest('Invalid email format');
      }
    }

    // Cek profile exist
    const existingProfile = await prisma.profile.findUnique({
      where: { id: userId },
    });

    if (!existingProfile) {
      throw AppError.notFound('User profile not found');
    }

    // Update di Prisma jika ada name dan photo
    const updateData: any = {};

    if (data.name !== undefined) {
      updateData.fullName = data.name.trim();
    }

    if (data.photo !== undefined) {
      updateData.avatarUrl = data.photo || null;
    }

    let updatedProfile = existingProfile;
    if (Object.keys(updateData).length > 0) {
      updatedProfile = await prisma.profile.update({
        where: { id: userId },
        data: updateData,
      });
    }

    // Update email di Supabase jika dikirim
    if (data.email !== undefined) {
      const { error } = await supabaseAdmin.auth.admin.updateUserById(userId, {
        email: data.email.trim(),
      });

      if (error) {
        throw AppError.badRequest(`Failed to update email: ${error.message}`);
      }
    }

    // Return updated profile data
    return {
      id: updatedProfile.id,
      name: updatedProfile.fullName,
      email: data.email !== undefined ? data.email.trim() : (await supabaseAdmin.auth.admin.getUserById(userId)).data.user?.email,
      photo: updatedProfile.avatarUrl,
      createdAt: updatedProfile.createdAt,
      updatedAt: updatedProfile.updatedAt,
    };
  }

  /**
   * Basic email validation
   */
  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
}
