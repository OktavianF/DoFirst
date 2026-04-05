"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = errorHandler;
const AppError_1 = require("../lib/AppError");
/**
 * Global error handler middleware.
 * Catches AppErrors and unexpected errors, returns consistent JSON responses.
 */
function errorHandler(err, _req, res, _next) {
    if (err instanceof AppError_1.AppError) {
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
//# sourceMappingURL=errorHandler.js.map