import { Request, Response, NextFunction } from 'express';
export interface AuthenticatedRequest extends Request {
    user: {
        id: string;
        email: string;
    };
}
/**
 * Middleware that verifies Supabase JWT from Authorization header.
 * Attaches the authenticated user to req.user.
 */
export declare function authMiddleware(req: Request, _res: Response, next: NextFunction): Promise<void>;
//# sourceMappingURL=auth.d.ts.map