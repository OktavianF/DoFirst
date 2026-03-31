import { Request, Response, NextFunction } from 'express';
import { AppError } from '../lib/AppError';

/**
 * Global error handler middleware.
 * Catches AppErrors and unexpected errors, returns consistent JSON responses.
 */
export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      success: false,
      error: err.message,
    });
    return;
  }

  // Log unexpected errors in development
  if (process.env.NODE_ENV === 'development') {
    console.error('Unexpected error:', err);
  }

  res.status(500).json({
    success: false,
    error: 'Internal server error',
  });
}
