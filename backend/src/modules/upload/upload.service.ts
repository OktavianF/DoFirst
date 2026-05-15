import { supabaseAdmin } from '../../lib/supabase';
import { prisma } from '../../lib/prisma';
import { AppError } from '../../lib/AppError';
import { randomUUID } from 'crypto';

export class UploadService {
  /**
   * Upload a file to Supabase Storage and return the public URL.
   */
  async uploadTaskAttachment(userId: string, taskId: string, file: {
    buffer: Buffer;
    originalname: string;
    mimetype: string;
    size: number;
  }) {
    // Verify the task belongs to the user
    const task = await prisma.task.findFirst({ where: { id: taskId, userId } });
    if (!task) {
      throw AppError.notFound('Task not found');
    }

    // Validate file size (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      throw AppError.badRequest('File too large. Maximum 10MB allowed.');
    }

    // Generate unique file path
    const ext = file.originalname.split('.').pop() || 'bin';
    const filePath = `${userId}/${taskId}/${randomUUID()}.${ext}`;

    // Upload to Supabase Storage
    const { error: uploadError } = await supabaseAdmin.storage
      .from('task-attachments')
      .upload(filePath, file.buffer, {
        contentType: file.mimetype,
        upsert: false,
      });

    if (uploadError) {
      throw AppError.badRequest(`Upload failed: ${uploadError.message}`);
    }

    // Get public URL
    const { data: urlData } = supabaseAdmin.storage
      .from('task-attachments')
      .getPublicUrl(filePath);

    const publicUrl = urlData.publicUrl;

    // Update task with file URL
    await prisma.task.update({
      where: { id: taskId },
      data: { fileUrl: publicUrl },
    });

    return {
      url: publicUrl,
      fileName: file.originalname,
      size: file.size,
    };
  }

  
  /**
   * Upload user avatar to Supabase Storage.
   */
  async uploadAvatar(userId: string, file: {
    buffer: Buffer;
    originalname: string;
    mimetype: string;
    size: number;
  }) {
    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      throw AppError.badRequest('File too large. Maximum 5MB allowed.');
    }

    const ext = file.originalname.split('.').pop() || 'jpg';
    const filePath = `${userId}/avatar.${ext}`;

    // Upload (upsert to replace existing avatar)
    const { error: uploadError } = await supabaseAdmin.storage
      .from('avatars')
      .upload(filePath, file.buffer, {
        contentType: file.mimetype,
        upsert: true,
      });

    if (uploadError) {
      throw AppError.badRequest(`Upload failed: ${uploadError.message}`);
    }

    const { data: urlData } = supabaseAdmin.storage
      .from('avatars')
      .getPublicUrl(filePath);

    const publicUrl = urlData.publicUrl;

    // Update profile
    await prisma.profile.update({
      where: { id: userId },
      data: { avatarUrl: publicUrl },
    });

    return {
      url: publicUrl,
      fileName: file.originalname,
    };
  }
}
