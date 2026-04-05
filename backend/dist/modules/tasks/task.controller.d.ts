import { Request, Response, NextFunction } from 'express';
export declare class TaskController {
    create(req: Request, res: Response, next: NextFunction): Promise<void>;
    list(req: Request, res: Response, next: NextFunction): Promise<void>;
    getById(req: Request, res: Response, next: NextFunction): Promise<void>;
    complete(req: Request, res: Response, next: NextFunction): Promise<void>;
}
//# sourceMappingURL=task.controller.d.ts.map