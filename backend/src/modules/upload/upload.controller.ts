import { Request, Response, NextFunction } from 'express';
import { UploadService } from './upload.service';
import { AuthenticatedRequest } from '../../middleware/auth';

const uploadService = new UploadService();

export class UploadController {
  async uploadTaskAttachment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const taskId = req.params.taskId;
      const file = req.file;

      if (!file) {
        res.status(400).json({ success: false, error: 'No file provided' });
        return;
      }

      if (!taskId) {
        res.status(400).json({ success: false, error: 'Task ID is required' });
        return;
      }

      const result = await uploadService.uploadTaskAttachment(user.id, taskId, {
        buffer: file.buffer,
        originalname: file.originalname,
        mimetype: file.mimetype,
        size: file.size,
      });

      res.status(201).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  async uploadAvatar(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const file = req.file;

      if (!file) {
        res.status(400).json({ success: false, error: 'No file provided' });
        return;
      }

      const result = await uploadService.uploadAvatar(user.id, {
        buffer: file.buffer,
        originalname: file.originalname,
        mimetype: file.mimetype,
        size: file.size,
      });

      res.json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }
}
