import { Request, Response, NextFunction } from 'express';
import { TaskService } from './task.service';
import { AuthenticatedRequest } from '../../middleware/auth';

const taskService = new TaskService();

export class TaskController {
  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const task = await taskService.createTask(user.id, req.body);

      res.status(201).json({
        success: true,
        data: task,
      });
    } catch (err) {
      next(err);
    }
  }

  async list(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const tasks = await taskService.getTasksByUser(user.id);

      res.json({
        success: true,
        data: tasks,
        count: tasks.length,
      });
    } catch (err) {
      next(err);
    }
  }

  async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const task = await taskService.getTaskById(user.id, req.params.id);

      res.json({
        success: true,
        data: task,
      });
    } catch (err) {
      next(err);
    }
  }

  async complete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { user } = req as AuthenticatedRequest;
      const result = await taskService.completeTask(user.id, req.params.id);

      res.json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }
}
