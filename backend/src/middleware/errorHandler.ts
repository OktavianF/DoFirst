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

  console.error("🔥 ERROR ASLI:", err); // WAJIB

  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      success: false,
      error: err.message,
    });
    return;
  }

  res.status(500).json({
    success: false,
    error: 'Internal server error',
  });
}
