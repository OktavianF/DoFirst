import { Request, Response, NextFunction } from 'express';
import { supabaseAdmin } from '../lib/supabase';
import { AppError } from '../lib/AppError';

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
export async function authMiddleware(
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw AppError.unauthorized('Missing or invalid Authorization header');
    }

    const token = authHeader.split(' ')[1];

    const {
      data: { user },
      error,
    } = await supabaseAdmin.auth.getUser(token);

    if (error || !user) {
      throw AppError.unauthorized('Invalid or expired token');
    }

    (req as AuthenticatedRequest).user = {
      id: user.id,
      email: user.email!,
    };

    next();
  } catch (err) {
    next(err);
  }
}
