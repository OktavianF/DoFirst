import { supabaseAdmin } from '../../lib/supabase';
import { prisma } from '../../lib/prisma';
import { AppError } from '../../lib/AppError';
import { randomUUID } from 'crypto';

function getMimeType(fileName: string, defaultMime: string): string {
  const ext = fileName.split('.').pop()?.toLowerCase();
  switch (ext) {
    // Images
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'svg':
      return 'image/svg+xml';
    case 'heic':
      return 'image/heic';
    // Documents
    case 'pdf':
      return 'application/pdf';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'txt':
      return 'text/plain';
    case 'csv':
      return 'text/csv';
    case 'zip':
      return 'application/zip';
    default:
      return defaultMime;
  }
}

export class UploadService {
  /**
   * Extract storage path from a public Supabase URL.
   */
  private getStoragePathFromUrl(bucketName: string, url: string): string | null {
    const parts = url.split(`/public/${bucketName}/`);
    if (parts.length > 1) {
      return parts[1];
    }
    return null;
  }

  /**
   * Delete a file from Supabase Storage by its public URL.
   */
  async deleteFileByUrl(bucketName: string, url: string): Promise<void> {
    const filePath = this.getStoragePathFromUrl(bucketName, url);
    if (!filePath) return;

    try {
      const { error } = await supabaseAdmin.storage
        .from(bucketName)
        .remove([filePath]);

      if (error) {
        console.error(`[Storage Clean] Failed to delete file from Supabase (${bucketName}): ${error.message}`);
      } else {
        console.log(`[Storage Clean] Successfully deleted file from Supabase (${bucketName}): ${filePath}`);
      }
    } catch (e) {
      console.error(`[Storage Clean] Error deleting file from Supabase (${bucketName}):`, e);
    }
  }

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

    // Resolve file extension
    let ext = file.originalname.split('.').pop()?.toLowerCase() || 'bin';

    const standardExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv', 'zip'];
    if (!standardExtensions.includes(ext) || ext.length > 5) {
      if (file.mimetype === 'image/jpeg') ext = 'jpg';
      else if (file.mimetype === 'image/png') ext = 'png';
      else if (file.mimetype === 'image/gif') ext = 'gif';
      else if (file.mimetype === 'image/webp') ext = 'webp';
      else if (file.mimetype === 'application/pdf') ext = 'pdf';
    }

    const filePath = `${userId}/${taskId}/${randomUUID()}.${ext}`;
    const resolvedMime = getMimeType(file.originalname, file.mimetype);

    // Delete existing attachment from storage if it exists to avoid storage leaks
    if (task.fileUrl) {
      console.log(`[Storage Clean] Task ${taskId} has old attachment. Deleting before new upload...`);
      await this.deleteFileByUrl('task-attachments', task.fileUrl);
    }

    // Upload to Supabase Storage
    const { error: uploadError } = await supabaseAdmin.storage
      .from('task-attachments')
      .upload(filePath, file.buffer, {
        contentType: resolvedMime,
        upsert: true,
      });

    if (uploadError) {
      console.error('[Storage Error] Supabase upload failed:', uploadError);
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

    let ext = file.originalname.split('.').pop()?.toLowerCase() || 'jpg';
    
    const standardExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'];
    if (!standardExtensions.includes(ext) || ext.length > 5) {
      if (file.mimetype === 'image/jpeg') ext = 'jpg';
      else if (file.mimetype === 'image/png') ext = 'png';
      else if (file.mimetype === 'image/gif') ext = 'gif';
      else if (file.mimetype === 'image/webp') ext = 'webp';
    }

    const filePath = `${userId}/avatar.${ext}`;
    const resolvedMime = getMimeType(file.originalname, file.mimetype);

    // Delete existing avatar from profile table if the filename or extension differs
    const profile = await prisma.profile.findUnique({ where: { id: userId } });
    if (profile?.avatarUrl) {
      const oldPath = this.getStoragePathFromUrl('avatars', profile.avatarUrl);
      if (oldPath && oldPath !== filePath) {
        console.log(`[Storage Clean] User ${userId} has old avatar. Deleting before new upload...`);
        await this.deleteFileByUrl('avatars', profile.avatarUrl);
      }
    }

    // Upload (upsert to replace existing avatar)
    const { error: uploadError } = await supabaseAdmin.storage
      .from('avatars')
      .upload(filePath, file.buffer, {
        contentType: resolvedMime,
        upsert: true,
      });

    if (uploadError) {
      console.error('[Storage Error] Supabase avatar upload failed:', uploadError);
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
