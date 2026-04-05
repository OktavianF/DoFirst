import { Request, Response, NextFunction } from 'express';
/**
 * Global error handler middleware.
 * Catches AppErrors and unexpected errors, returns consistent JSON responses.
 */
export declare function errorHandler(err: Error, _req: Request, res: Response, _next: NextFunction): void;
//# sourceMappingURL=errorHandler.d.ts.map