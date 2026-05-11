import { Request, Response, NextFunction } from 'express';
import { createSupabaseClient } from '../lib/supabase';
import { AppError } from '../lib/AppError';

export interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    email: string;
  };
}

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

    const supabase = createSupabaseClient(token);

    const {
      data: { user },
      error,
    } = await supabase.auth.getUser();

    console.log("USER:", user); // optional debug

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